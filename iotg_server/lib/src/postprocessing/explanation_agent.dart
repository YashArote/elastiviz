import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../agents/metric_resolver.dart';

/// Explanation Agent — uses Gemini to produce a grounded, factual explanation.
///
/// The LLM receives:
///   - Entity name and type (human-readable)
///   - Summary stats  (min, max, avg) per metric using display names
///   - List of detected anomalies with severity + reason
///
/// The LLM NEVER sees: ECS field paths, index names, datasets, ES|QL.
class ExplanationAgent {
  final Session _session;

  ExplanationAgent(this._session);

  /// Generic explanation — called by the new Elastic Agent Builder pipeline.
  /// Takes raw field path stats + anomaly list directly.
  Future<String> explainGeneric({
    required String entityName,
    required String entityType,
    required String timeWindow,
    required List<Map<String, dynamic>> rows,
    required List<String> metricNames,
    required List<AnomalyEntry> anomalies,
    String esql = '', // used to detect nanocores in STATS queries
  }) async {
    final apiKey =
        _session.passwords['geminiApiKey'] ?? 'PLACEHOLDER_GEMINI_API_KEY';

    final metricSummary = _buildMetricSummaryFromPaths(
      rows,
      metricNames,
      esql: esql,
    );
    final anomalySummary = _buildAnomalySummary(anomalies);

    final prompt =
        '''You are an infrastructure observability expert.
Write a concise, factual, 2-4 sentence explanation for what you see in this monitoring data.

Observation context:
- Resource: $entityName ($entityType)
- Time window: $timeWindow

Metric summary:
$metricSummary

${anomalySummary.isNotEmpty ? 'Detected anomalies:\n$anomalySummary' : 'No anomalies detected.'}

Rules:
- Be factual — only describe what is in the data
- Do NOT mention field paths, database names, queries, or schema terms
- Use human-readable names (CPU Usage, Memory Usage) — never ECS field paths
- Keep it to 2-4 sentences, plain English only''';

    try {
      return await _callGemini(apiKey, prompt);
    } catch (e) {
      _session.log(
        '[ExplanationAgent] explainGeneric failed: $e',
        level: LogLevel.warning,
      );
      return _fallbackExplanation(
        entityName,
        entityType,
        metricSummary,
        anomalies,
      );
    }
  }

  /// Legacy: explain() using ResolvedMetric list (old pipeline).
  Future<String> explain({
    required Map<String, dynamic> plan,
    required List<Map<String, dynamic>> rows,
    required List<ResolvedMetric> metrics,
    required List<AnomalyEntry> anomalies,
  }) async {
    final apiKey =
        _session.passwords['geminiApiKey'] ?? 'PLACEHOLDER_GEMINI_API_KEY';

    final entityName = plan['entity_name'] as String;
    final entityType = plan['entity_type'] as String;
    final timeWindow = plan['time_window'] as String? ?? '30m';

    final metricSummary = _buildMetricSummary(rows, metrics);
    final anomalySummary = _buildAnomalySummary(anomalies);

    final prompt =
        '''You are an observability expert.
Write a concise, factual, 2-4 sentence explanation for what you see in this monitoring data.

Observation context:
- Resource: $entityName ($entityType)
- Time window: $timeWindow

Metric summary:
$metricSummary

${anomalySummary.isNotEmpty ? 'Detected anomalies:\n$anomalySummary' : 'No anomalies detected.'}

Rules:
- Be factual — only describe what is in the data
- Do NOT mention field paths, database names, query languages, or schema terms
- Keep it to 2-4 sentences, plain English''';

    try {
      return await _callGemini(apiKey, prompt);
    } catch (e) {
      _session.log(
        '[ExplanationAgent] Failed: $e',
        level: LogLevel.warning,
      );
      return _fallbackExplanation(
        entityName,
        entityType,
        metricSummary,
        anomalies,
      );
    }
  }

  String _buildMetricSummary(
    List<Map<String, dynamic>> rows,
    List<ResolvedMetric> metrics,
  ) {
    final sb = StringBuffer();
    for (final metric in metrics) {
      final vals = rows
          .map((r) => r[metric.fieldPath])
          .whereType<num>()
          .map((v) => v.toDouble())
          .toList();
      if (vals.isEmpty) continue;
      vals.sort();
      final min = vals.first;
      final max = vals.last;
      final avg = vals.fold(0.0, (a, b) => a + b) / vals.length;
      sb.writeln(
        '- ${metric.displayName}: min=${_fmt(min, metric.unit)} '
        'avg=${_fmt(avg, metric.unit)} max=${_fmt(max, metric.unit)}',
      );
    }
    return sb.toString().trim();
  }

  String _buildMetricSummaryFromPaths(
    List<Map<String, dynamic>> rows,
    List<String> fieldPaths, {
    String esql = '',
  }) {
    final esqlUsesNanocores = esql.contains('nanocores');
    final sb = StringBuffer();
    for (final path in fieldPaths) {
      final name = _displayNameFromPath(path);
      final vals = rows
          .map((r) => r[path])
          .whereType<num>()
          .map((v) => v.toDouble())
          .toList();
      if (vals.isEmpty) continue;
      vals.sort();
      final avg = vals.fold(0.0, (a, b) => a + b) / vals.length;
      // For STATS queries, column names like max_val don't contain 'nanocores',
      // so we fall back to checking the esql string.
      final effectivePath = esqlUsesNanocores && !path.contains('nanocores')
          ? 'nanocores'
          : path;
      final unit = _unitFromPath(effectivePath);
      sb.writeln(
        '- $name: min=${_fmtAuto(vals.first, effectivePath)} '
        'avg=${_fmtAuto(avg, effectivePath)} max=${_fmtAuto(vals.last, effectivePath)} [$unit]',
      );
    }
    return sb.toString().trim();
  }

  /// Returns the human-readable unit label for a field path.
  String _unitFromPath(String path) {
    if (path.contains('nanocores')) return 'cores';
    if (path.contains('.pct')) return '%';
    if (path.contains('bytes') || path.contains('memory')) return 'bytes';
    return '';
  }

  /// Formats a raw field value with automatic unit conversion and capping.
  String _fmtAuto(double raw, String fieldPath) {
    if (fieldPath.contains('nanocores')) {
      // nanocores → cores, capped to 3 decimals
      return '${(raw / 1e9).toStringAsFixed(2)} cores';
    }
    if (fieldPath.contains('.pct')) {
      // fraction 0–1 → percentage
      return '${(raw * 100).toStringAsFixed(1)}%';
    }
    if (fieldPath.contains('bytes') || fieldPath.contains('memory')) {
      return _fmt(raw, 'bytes');
    }
    // Generic: cap at 2 decimals, no G/M abbreviations in natural language
    if (raw.abs() >= 1e9) return '${(raw / 1e9).toStringAsFixed(2)}G';
    if (raw.abs() >= 1e6) return '${(raw / 1e6).toStringAsFixed(2)}M';
    if (raw.abs() >= 1e3) return '${(raw / 1e3).toStringAsFixed(2)}K';
    return raw.toStringAsFixed(2);
  }

  String _displayNameFromPath(String path) {
    const names = {
      'cpu': 'CPU Usage',
      'memory': 'Memory Usage',
      'network': 'Network Usage',
      'disk': 'Disk Usage',
      'load': 'System Load',
    };
    for (final k in names.keys) {
      if (path.contains(k)) return names[k]!;
    }
    final last = path.split('.').last;
    return last[0].toUpperCase() + last.substring(1);
  }

  String _fmt(double val, String unit) {
    if (unit == 'bytes') {
      if (val > 1e9) return '${(val / 1e9).toStringAsFixed(1)} GB';
      if (val > 1e6) return '${(val / 1e6).toStringAsFixed(1)} MB';
      if (val > 1e3) return '${(val / 1e3).toStringAsFixed(1)} KB';
      return '${val.toStringAsFixed(0)} B';
    }
    if (unit == '%') return '${(val * 100).toStringAsFixed(1)}%';
    return '${val.toStringAsFixed(2)} $unit';
  }

  String _buildAnomalySummary(List<AnomalyEntry> anomalies) {
    if (anomalies.isEmpty) return '';
    final sb = StringBuffer();
    for (final a in anomalies.take(5)) {
      sb.writeln(
        '- [${a.severity.toUpperCase()}] ${a.metric} at ${a.timestamp}: ${a.reason}',
      );
    }
    if (anomalies.length > 5) {
      sb.writeln('- ... and ${anomalies.length - 5} more anomalies');
    }
    return sb.toString().trim();
  }

  String _fallbackExplanation(
    String entityName,
    String entityType,
    String metricSummary,
    List<AnomalyEntry> anomalies,
  ) {
    final lines = metricSummary
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    final sb = StringBuffer();
    sb.write('Monitoring data for $entityType');
    if (entityName != '*' && entityName.isNotEmpty) {
      sb.write(' "$entityName"');
    }
    sb.write(': ');
    if (lines.isNotEmpty) {
      // Convert '- CPU Usage: min=0.71 cores avg=0.87 cores max=1.98 cores [cores]'
      // into 'CPU Usage ranged from 0.71 to 1.98 (avg 0.87) cores.'
      final summaries = lines
          .map((l) {
            final clean = l.replaceAll(RegExp(r'^-\s*'), '');
            // Extract label and stats
            final colonIdx = clean.indexOf(':');
            if (colonIdx == -1) return clean;
            final label = clean.substring(0, colonIdx).trim();
            final stats = clean.substring(colonIdx + 1).trim();
            final minM = RegExp(r'min=(.+?)\s+avg=').firstMatch(stats);
            final avgM = RegExp(r'avg=(.+?)\s+max=').firstMatch(stats);
            final maxM = RegExp(r'max=(.+?)(?:\s*\[|$)').firstMatch(stats);
            if (minM != null && avgM != null && maxM != null) {
              return '$label ranged from ${minM.group(1)} to ${maxM.group(1)} '
                  '(avg ${avgM.group(1)})';
            }
            return clean;
          })
          .join('; ');
      sb.write('$summaries. ');
    }
    if (anomalies.isNotEmpty) {
      final high = anomalies.where((a) => a.severity == 'high').length;
      final med = anomalies.where((a) => a.severity == 'medium').length;
      final parts = <String>[];
      if (high > 0) parts.add('$high high-severity');
      if (med > 0) parts.add('$med medium-severity');
      sb.write('${parts.join(' and ')} anomalies were detected.');
    } else {
      sb.write('No anomalies were detected in this time window.');
    }
    return sb.toString();
  }

  Future<String> _callGemini(String apiKey, String prompt) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 200,
      },
    });

    final response = await http.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini explanation error [${response.statusCode}]: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = (data['candidates'] as List?) ?? [];
    if (candidates.isEmpty) return '';
    final parts = (candidates.first['content']['parts'] as List?) ?? [];
    return (parts.firstOrNull?['text'] as String? ?? '').trim();
  }
}
