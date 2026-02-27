import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../schema/elasticsearch_client.dart';
import '../../esql/esql_compiler.dart';
import '../../agents/agent_result_cache.dart';

/// HTTP routes exposed for Elastic Agent Builder tool webhooks.
///
/// Agent Builder calls these when the agent executes a tool.
/// Register in server.dart:
///   pod.webServer.addRoute(CapabilityRegistryRoute(), '/tools/capability-registry');
///   pod.webServer.addRoute(ValidatePlanRoute(),        '/tools/validate-plan');
///   pod.webServer.addRoute(CompileEsqlRoute(),         '/tools/compile-esql');
///   pod.webServer.addRoute(RunEsqlRoute(),             '/tools/run-esql');
///
/// Configure each tool in Kibana Agent Builder UI as:
///   Method: POST (or GET for capability-registry)
///   URL: https://<ngrok-or-deployed-url>/tools/<name>

Response _json(Map<String, dynamic> data, {int status = 200}) => Response(
  status,
  body: Body.fromString(jsonEncode(data), mimeType: MimeType.json),
);

Future<Map<String, dynamic>> _readBody(Request request) async {
  final body = await request.readAsString();
  if (body.isEmpty) return {};
  return jsonDecode(body) as Map<String, dynamic>;
}

// ─── Tool 1: /tools/capability-registry ──────────────────────────────────────

class CapabilityRegistryRoute extends Route {
  @override
  Future<Response> handleCall(Session session, Request request) async {
    try {
      final row = await CapabilityRegistry.db.findFirstRow(session);
      if (row == null) {
        return _json({
          'error': 'Capability registry not ready. Schema ingestion pending.',
        }, status: 503);
      }
      final registry = jsonDecode(row.registryJson) as Map<String, dynamic>;
      return _json(registry);
    } catch (e) {
      session.log('[CapabilityRegistryRoute] $e', level: LogLevel.error);
      return _json({'error': e.toString()}, status: 500);
    }
  }
}

// ─── Tool 2: /tools/validate-plan ────────────────────────────────────────────

class ValidatePlanRoute extends Route {
  static const Map<String, String> _entityFilterFields = {
    'pod': 'kubernetes.pod.name',
    'node': 'kubernetes.node.name',
    'service': 'service.name',
    'container': 'kubernetes.container.name',
    'namespace': 'kubernetes.namespace',
  };

  @override
  Future<Response> handleCall(Session session, Request request) async {
    try {
      final body = await _readBody(request);
      final entityType = (body['entity_type'] as String? ?? '').toLowerCase();
      final entityName = body['entity_name'] as String? ?? '';
      final metrics = (body['metrics'] as List? ?? []).cast<String>();
      final timeWindow = body['time_window'] as String? ?? '30m';

      final capRow = await CapabilityRegistry.db.findFirstRow(session);
      if (capRow == null) {
        return _json({
          'valid': false,
          'error': 'Capability registry not ready',
        });
      }

      final registry = jsonDecode(capRow.registryJson) as Map<String, dynamic>;
      final entities = registry['entities'] as Map<String, dynamic>? ?? {};

      if (!entities.containsKey(entityType)) {
        return _json({
          'valid': false,
          'error':
              'Unknown entity_type "$entityType". Available: ${entities.keys.join(", ")}',
        });
      }

      final caps = entities[entityType] as Map<String, dynamic>;
      final available = (caps['metrics'] as List).cast<String>();
      final resolvedMetrics = metrics.where(available.contains).toList();

      if (resolvedMetrics.isEmpty) {
        return _json({
          'valid': false,
          'error':
              'None of $metrics available for $entityType. Available: $available',
        });
      }

      // Resolve ECS field paths from MetricDictionary
      final fieldPaths = <String>[];
      String? dataset;
      for (final metric in resolvedMetrics) {
        final row = await MetricDictionary.db.findFirstRow(
          session,
          where: (t) =>
              t.category.equals(metric) & t.entityType.equals(entityType),
        );
        if (row != null) {
          fieldPaths.add(row.fieldPath);
          dataset ??= row.dataset;
        }
      }

      if (fieldPaths.isEmpty || dataset == null) {
        return _json({
          'valid': false,
          'error':
              'No fields in MetricDictionary for $entityType/$resolvedMetrics',
        });
      }

      final filterField =
          _entityFilterFields[entityType] ??
          caps['filter_field'] as String? ??
          'kubernetes.$entityType.name';
      final indexPattern = dataset.contains('log')
          ? 'logs-$dataset*'
          : 'metrics-$dataset*';

      return _json({
        'valid': true,
        'dataset': dataset,
        'index_pattern': indexPattern,
        'entity_filter': {'field': filterField, 'value': entityName},
        'metrics': resolvedMetrics,
        'field_paths': fieldPaths,
        'time_window': timeWindow,
      });
    } catch (e) {
      session.log('[ValidatePlanRoute] $e', level: LogLevel.error);
      return _json({'valid': false, 'error': e.toString()}, status: 500);
    }
  }
}

// ─── Tool 3: /tools/compile-esql ─────────────────────────────────────────────

class CompileEsqlRoute extends Route {
  @override
  Future<Response> handleCall(Session session, Request request) async {
    try {
      final body = await _readBody(request);
      final indexPattern = body['index_pattern'] as String? ?? '';
      final filterField = body['entity_filter_field'] as String? ?? '';
      final filterValue = body['entity_filter_value'] as String? ?? '';
      final fieldPaths = (body['metric_field_paths'] as List? ?? [])
          .cast<String>();
      final timeWindow = body['time_window'] as String? ?? '30m';

      if (indexPattern.isEmpty || filterField.isEmpty || fieldPaths.isEmpty) {
        return _json({
          'error':
              'Missing: index_pattern, entity_filter_field, metric_field_paths',
        }, status: 400);
      }

      final esql = EsqlCompiler().buildFromFields(
        indexPattern: indexPattern,
        filterField: filterField,
        filterValue: filterValue,
        fieldPaths: fieldPaths,
        timeWindow: timeWindow,
      );

      session.log(
        '[CompileEsqlRoute] OK: ${esql.substring(0, esql.length.clamp(0, 80))}...',
      );
      return _json({'esql': esql});
    } catch (e) {
      session.log('[CompileEsqlRoute] $e', level: LogLevel.error);
      return _json({'error': e.toString()}, status: 500);
    }
  }
}

// ─── Tool 4: /tools/run-esql ─────────────────────────────────────────────────

class RunEsqlRoute extends Route {
  /// Max rows sent back to the Kibana agent.
  /// 1000 raw rows blows the LLM context window; 300 evenly-sampled points
  /// preserve the shape of any time series while keeping the payload small.
  static const _maxAgentRows = 300;

  @override
  Future<Response> handleCall(Session session, Request request) async {
    try {
      final body = await _readBody(request);
      final esql = body['esql'] as String? ?? '';
      if (esql.isEmpty) {
        return _json({'error': 'esql is required'}, status: 400);
      }
      final client = ElasticsearchClient.fromSession(session);
      final rows = await client.runEsql(esql);
      session.log('[RunEsqlRoute] ${rows.length} rows returned');

      // Downsample before returning to agent to protect context window
      final agentRows = rows.length > _maxAgentRows
          ? _downsample(rows, _maxAgentRows)
          : rows;

      // Cache the result for "REF:LAST_RUN" optimization
      if (esql.isNotEmpty) {
        AgentResultCache.store(esql, rows); // store FULL results, not sampled
      }

      return _json({
        'rows': agentRows,
        'count': rows.length, // original row count
        'sampled': agentRows.length, // rows actually returned
      });
    } catch (e) {
      session.log('[RunEsqlRoute] $e', level: LogLevel.error);
      return _json({'error': e.toString()}, status: 500);
    }
  }

  /// Entity-aware downsampler — groups by pod/node/service name first,
  /// then even-samples each entity independently so every entity keeps
  /// proportional representation regardless of data density.
  List<Map<String, dynamic>> _downsample(
    List<Map<String, dynamic>> rows,
    int target,
  ) {
    if (rows.length <= target) return rows;

    const entityColumns = [
      'kubernetes.pod.name',
      'kubernetes.node.name',
      'service.name',
      'kubernetes.container.name',
      'kubernetes.namespace',
    ];
    final columns = rows.first.keys.toSet();
    final entityCol = entityColumns.firstWhere(
      columns.contains,
      orElse: () => '',
    );

    if (entityCol.isEmpty) return _evenSample(rows, target);

    final groups = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      groups.putIfAbsent(row[entityCol]?.toString() ?? '', () => []).add(row);
    }

    final perEntity = (target / groups.length).ceil().clamp(5, target);
    final result = <Map<String, dynamic>>[];
    for (final g in groups.values) {
      result.addAll(g.length <= perEntity ? g : _evenSample(g, perEntity));
    }
    return result.length <= target ? result : _evenSample(result, target);
  }

  List<Map<String, dynamic>> _evenSample(
    List<Map<String, dynamic>> rows,
    int target,
  ) {
    if (rows.length <= target) return rows;
    final step = (rows.length - 1) / (target - 1);
    return [for (var i = 0; i < target; i++) rows[(i * step).round()]];
  }
}
