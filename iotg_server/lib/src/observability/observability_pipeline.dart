import 'dart:async';
import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../elastic/elastic_agent_client.dart';
import '../postprocessing/anomaly_detector.dart';
import '../postprocessing/explanation_agent.dart';
import '../agents/agent_result_cache.dart';

/// Orchestrates the Elastic Agent Builder pipeline:
///   1. ElasticAgentClient  → natural language → structured JSON (via Kibana)
///   2. AnomalyDetector     → local math on returned rows
///   3. ExplanationAgent    → Gemini grounded explanation
///   4. ChartBuilder        → Flutter output contract (line | bar | stat)
class ObservabilityPipeline {
  final Session _session;

  ObservabilityPipeline(this._session);

  Future<ChatResponse> run(String userQuery, {String? conversationId}) async {
    _session.log('[Pipeline] Starting for query: $userQuery');

    // ── Step 1: Elastic Agent Builder ────────────────────────────────────────
    final agentResp = await ElasticAgentClient(
      _session,
    ).chat(userQuery, conversationId: conversationId);

    final agentResult = agentResp.data;
    final returnedConversationId = agentResp.conversationId;

    _session.log('[Pipeline] Agent status: ${agentResult['status']}');

    if (agentResult['status'] == 'error') {
      return _error(
        agentResult['error_message']?.toString() ??
            'The agent could not answer this query.',
        conversationId: returnedConversationId,
      );
    }

    final rawRows = agentResult['rows'];
    final esql = agentResult['esql'] as String? ?? '';
    List<Map<String, dynamic>> rows;

    if (rawRows == 'REF:LAST_RUN') {
      _session.log(
        '[Pipeline] Agent returned REF:LAST_RUN. Resolving from cache...',
      );

      // Primary lookup: By ESQL string (most reliable)
      var cached = esql.isNotEmpty ? AgentResultCache.retrieve(esql) : null;

      // Secondary fallback: By conversation ID
      cached ??= AgentResultCache.retrieve(returnedConversationId);

      if (cached == null) {
        _session.log(
          '[Pipeline] ERROR: No rows found in cache for query: $esql',
          level: LogLevel.error,
        );
        return _error(
          'Agent used a reference but data could not be resolved. '
          'Please try asking again.',
          conversationId: returnedConversationId,
        );
      }
      rows = cached;
    } else if (rawRows is List) {
      rows = rawRows.cast<Map<String, dynamic>>();
    } else if (rawRows is Map) {
      // Defensive flatten for Map responses
      rows = rawRows.values
          .whereType<List>()
          .expand((v) => v.cast<Map<String, dynamic>>())
          .toList();
    } else {
      rows = [];
    }

    if (rows.isEmpty) {
      return _error(
        'No data found for this query. '
        'The entity may not exist or there is no data in the requested window.',
        conversationId: returnedConversationId,
      );
    }

    final intent = agentResult['intent'] as Map<String, dynamic>? ?? {};
    final plan = agentResult['plan'] as Map<String, dynamic>? ?? {};
    // esql is already defined above

    final entityType = intent['entity_type'] as String? ?? 'unknown';
    final entityName = intent['entity_name'] as String? ?? 'unknown';
    final timeWindow = intent['time_window'] as String? ?? '30m';

    // Trust the agent's chart_type. After Kibana prompt update it returns
    // 'bar' for compare-across-entities and 'stat' for single-value.
    // Default to 'line' (time series) for all other queries.
    final chartType = agentResult['chart_type'] as String? ?? 'line';

    // ── Step 2: Anomaly Detection (pure Dart math, no LLM) ───────────────────
    final metricNames = _buildMetricNames(rows);
    final anomalies = AnomalyDetector().detectFromRows(rows, metricNames);
    _session.log('[Pipeline] Detected ${anomalies.length} anomalies');

    // ── Steps 3+4: Gemini explanation and chart JSON run concurrently ──────────
    // Both only need rows+metricNames+anomalies — no dependency between them.
    final explanationFuture = ExplanationAgent(_session).explainGeneric(
      entityName: entityName,
      entityType: entityType,
      timeWindow: timeWindow,
      rows: rows,
      metricNames: metricNames,
      anomalies: anomalies,
      esql: esql, // used to detect nanocores in STATS queries
    );
    final chartJson = _buildChartJson(
      rows,
      metricNames,
      anomalies,
      chartType,
      esql: esql,
    );
    final explanation = await explanationFuture;

    // ── Step 5: Persist fire-and-forget ───────────────────────────────────────
    // Don't await — Flutter gets the response ~0.5s+ sooner.
    unawaited(
      _persistAsync(
        userQuery,
        intent,
        plan,
        esql,
        chartJson,
        explanation,
        anomalies,
      ),
    );

    return ChatResponse(
      status: 'success',
      explanation: explanation,
      chartJson: chartJson,
      queryId: null, // persisted in background
      conversationId: returnedConversationId,
    );
  }

  /// DB persist runs after ChatResponse is already returned to Flutter.
  Future<void> _persistAsync(
    String userQuery,
    Map<String, dynamic> intent,
    Map<String, dynamic> plan,
    String esql,
    String chartJson,
    String explanation,
    List<AnomalyEntry> anomalies,
  ) async {
    try {
      final savedQuery = await ObservabilityQuery.db.insertRow(
        _session,
        ObservabilityQuery(
          userQuery: userQuery,
          intentJson: jsonEncode(intent),
          planJson: jsonEncode(plan),
          esqlQuery: esql,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      await ObservabilityResult.db.insertRow(
        _session,
        ObservabilityResult(
          queryId: savedQuery.id!,
          chartJson: chartJson,
          explanation: explanation,
          hasAnomalies: anomalies.isNotEmpty,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      _session.log(
        '[Pipeline] Persist failed (non-fatal): $e',
        level: LogLevel.warning,
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns only numeric columns — skips entity-name strings like
  /// `kubernetes.node.name` that appear in all-entity wildcard queries.
  List<String> _buildMetricNames(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return [];
    return rows.first.keys
        .where((k) => k != '@timestamp' && !k.startsWith('_'))
        .where((k) => rows.first[k] is num)
        .toList();
  }

  /// Finds the entity-label column (string-valued, non-timestamp) present in
  /// wildcard queries so the bar chart can group by it.
  String? _findEntityColumn(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return null;
    return rows.first.keys
        .where((k) => k != '@timestamp' && !k.startsWith('_'))
        .where((k) => rows.first[k] is String)
        .firstOrNull;
  }

  String _buildChartJson(
    List<Map<String, dynamic>> rows,
    List<String> fieldPaths,
    List<AnomalyEntry> anomalies,
    String chartType, {
    String esql = '',
  }) {
    // Detect if the underlying query involved nanocores — needed for STATS queries
    // where columns are renamed to max_val/avg_val and don't contain 'nanocores'.
    final esqlUsesNanocores = esql.contains('nanocores');

    final anomalyList = anomalies
        .map(
          (a) => {
            'timestamp': a.timestamp,
            'metric': a.metric,
            'severity': a.severity,
            'reason': a.reason,
          },
        )
        .toList();

    // ── stat: single big-number ────────────────────────────────────────────
    if (chartType == 'stat' && rows.isNotEmpty && fieldPaths.isNotEmpty) {
      final field = fieldPaths.first;
      final val = (rows.last[field] as num?)?.toDouble() ?? 0.0;
      return jsonEncode({
        'type': 'stat',
        'stat_value': val,
        'stat_metric': _displayName(field),
        'stat_unit': _inferUnit(field),
        'series': _buildSeries(
          rows,
          fieldPaths,
          esqlUsesNanocores: esqlUsesNanocores,
        ),
        'anomalies': anomalyList,
      });
    }

    // ── bar: one bar per entity, avg value per metric ──────────────────────
    if (chartType == 'bar') {
      final entityCol = _findEntityColumn(rows);
      if (entityCol != null) {
        final groups = <String, Map<String, List<double>>>{};
        for (final row in rows) {
          final entity = row[entityCol]?.toString() ?? 'unknown';
          groups.putIfAbsent(entity, () => {});
          for (final field in fieldPaths) {
            final v = (row[field] as num?)?.toDouble();
            if (v != null) {
              groups[entity]!.putIfAbsent(field, () => []).add(v);
            }
          }
        }
        final barData = groups.entries.map((e) {
          final avgValues = <String, double>{};
          for (final m in e.value.entries) {
            // Scale nanocores → cores. Check both column name AND esql string
            // (STATS queries rename columns to max_val/avg_val).
            final isNanocores =
                m.key.contains('nanocores') || esqlUsesNanocores;
            final scale = isNanocores ? 1e-9 : 1.0;
            avgValues[_displayName(m.key)] =
                (m.value.reduce((a, b) => a + b) / m.value.length) * scale;
          }
          return {'label': e.key, 'values': avgValues};
        }).toList();

        // bar_unit: prefer esql-detected type over field path inference
        final barUnit = esqlUsesNanocores
            ? 'cores'
            : (fieldPaths.isNotEmpty ? _inferUnit(fieldPaths.first) : '');

        return jsonEncode({
          'type': 'bar',
          'bar_data': barData,
          'bar_unit': barUnit,
          'series': _buildSeries(
            rows,
            fieldPaths,
            esqlUsesNanocores: esqlUsesNanocores,
          ),
          'anomalies': anomalyList,
        });
      }
    }

    // ── line: default time-series ──────────────────────────────────────────
    return jsonEncode({
      'type': 'line',
      'x_axis': 'timestamp',
      'series': _buildSeries(
        rows,
        fieldPaths,
        esqlUsesNanocores: esqlUsesNanocores,
      ),
      'anomalies': anomalyList,
    });
  }

  List<Map<String, dynamic>> _buildSeries(
    List<Map<String, dynamic>> rows,
    List<String> fieldPaths, {
    bool esqlUsesNanocores = false,
  }) {
    final series = <Map<String, dynamic>>[];
    final entityCol = _findEntityColumn(rows);

    for (final field in fieldPaths) {
      // Nanocores → cores. Also handle STATS queries where column name is max_val/avg_val.
      final isNanocores = field.contains('nanocores') || esqlUsesNanocores;
      final scale = isNanocores ? 1e-9 : 1.0;
      final unit = isNanocores ? 'cores' : _inferUnit(field);
      final metricLabel = _displayName(field);

      if (entityCol != null) {
        // Multi-entity query: create ONE series per entity (one line per node/pod).
        // Rows contain a mix of all entities — group them by entity name.
        final entityGroups = <String, List<Map<String, dynamic>>>{};
        for (final row in rows) {
          final entity = row[entityCol]?.toString();
          if (entity == null) continue; // skip null entity rows
          entityGroups.putIfAbsent(entity, () => []).add(row);
        }
        for (final entry in entityGroups.entries) {
          final entityName = entry.key;
          final data = <List<dynamic>>[];
          for (final row in entry.value) {
            final ts = row['@timestamp'];
            final val = row[field];
            if (ts == null || val == null) continue;
            final num? numVal = val is num
                ? val
                : double.tryParse(val.toString());
            if (numVal == null) continue;
            data.add([ts.toString(), numVal.toDouble() * scale]);
          }
          if (data.isEmpty) continue;
          series.add({
            // Short entity identifier at the end of the series name
            'name': '${metricLabel} — $entityName',
            'field': field,
            'unit': unit,
            'data': data,
          });
        }
      } else {
        // Single entity: one series
        final data = <List<dynamic>>[];
        for (final row in rows) {
          final ts = row['@timestamp'];
          final val = row[field];
          if (ts == null || val == null) continue;
          final num? numVal = val is num
              ? val
              : double.tryParse(val.toString());
          if (numVal == null) continue;
          data.add([ts.toString(), numVal.toDouble() * scale]);
        }
        series.add({
          'name': metricLabel,
          'field': field,
          'unit': unit,
          'data': data,
        });
      }
    }
    return series;
  }

  String _displayName(String fieldPath) {
    const known = {
      'cpu': 'CPU Usage',
      'memory': 'Memory Usage',
      'network': 'Network Usage',
      'disk': 'Disk Usage',
      'load': 'System Load',
    };
    for (final k in known.keys) {
      if (fieldPath.contains(k)) return known[k]!;
    }
    final last = fieldPath.split('.').last;
    return last[0].toUpperCase() + last.substring(1);
  }

  String _inferUnit(String fieldPath) {
    if (fieldPath.contains('nanocores'))
      return 'cores'; // values are pre-scaled ÷1e9
    if (fieldPath.contains('.bytes') || fieldPath.contains('_bytes'))
      return 'bytes';
    if (fieldPath.contains('.pct') || fieldPath.contains('_pct')) return '%';
    if (fieldPath.contains('cpu')) return 'cores';
    if (fieldPath.contains('memory')) return 'bytes';
    return '';
  }

  ChatResponse _error(String message, {String? conversationId}) => ChatResponse(
    status: 'error',
    explanation: message,
    chartJson: null,
    queryId: null,
    conversationId: conversationId,
  );
}
