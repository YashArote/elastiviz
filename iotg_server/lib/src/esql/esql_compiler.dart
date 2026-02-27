import '../agents/metric_resolver.dart';

/// ES|QL Compiler — deterministic string builder.
/// ⚠️ The LLM NEVER touches this class.
///
/// Two entry points:
///   buildFromFields()  — primary, accepts raw ECS field paths (Elastic Agent tool)
///   build()            — legacy, accepts ResolvedMetric list
class EsqlCompiler {
  /// Builds an ES|QL query from resolved ECS field paths.
  /// Used by ElasticAgentClient's compile_esql tool.
  String buildFromFields({
    required String indexPattern,
    required String filterField,
    required String filterValue,
    required List<String> fieldPaths,
    required String timeWindow,
  }) {
    if (fieldPaths.isEmpty) {
      throw ArgumentError('Cannot build ES|QL: no field paths provided');
    }
    final duration = _parseTimeWindow(timeWindow);
    final keepFields = ['@timestamp', ...fieldPaths.toSet()];
    final isWildcard =
        filterValue.isEmpty ||
        filterValue == '*' ||
        filterValue.toLowerCase() == 'all';

    final lines = [
      'FROM $indexPattern',
      // Only add entity filter when a specific entity is requested.
      // '*' / 'all' / empty → show data for all entities.
      if (!isWildcard)
        '| WHERE $filterField == "${_escapeString(filterValue)}"',
      '| WHERE @timestamp > NOW() - $duration',
      // For "all entities" queries, keep the entity field for grouping context
      if (isWildcard)
        '| KEEP $filterField, ${keepFields.join(', ')}'
      else
        '| KEEP ${keepFields.join(', ')}',
      '| SORT @timestamp ASC',
      '| LIMIT 400',
    ];
    return lines.join('\n');
  }

  /// Builds an ES|QL query from the execution plan and resolved metrics.
  ///
  /// [plan] — from PlanningAgent.plan()
  /// [metrics] — from MetricResolver.resolve()
  String build({
    required Map<String, dynamic> plan,
    required List<ResolvedMetric> metrics,
  }) {
    if (metrics.isEmpty) {
      throw ArgumentError('Cannot build ES|QL: no metrics resolved');
    }

    final dataset = plan['dataset'] as String;
    final entityFilter = plan['entity_filter'] as Map<String, dynamic>;
    final filterField = entityFilter['field'] as String;
    final filterValue = entityFilter['value'] as String;
    final timeWindow = _parseTimeWindow(
      plan['time_window'] as String? ?? '30m',
    );

    final indexPattern = dataset.contains('log')
        ? 'logs-$dataset*'
        : 'metrics-$dataset*';

    final keepFields = <String>['@timestamp'];
    for (final m in metrics) {
      if (!keepFields.contains(m.fieldPath)) {
        keepFields.add(m.fieldPath);
      }
    }

    return [
      'FROM $indexPattern',
      '| WHERE $filterField == "${_escapeString(filterValue)}"',
      '| WHERE @timestamp > NOW() - $timeWindow',
      '| KEEP ${keepFields.join(',\n       ')}',
      '| SORT @timestamp ASC',
      '| LIMIT 1000',
    ].join('\n');
  }

  /// Parses "30m", "1h", "24h" into "30 minutes", "1 hours", etc.
  String _parseTimeWindow(String tw) {
    final lower = tw.toLowerCase().trim();
    final numStr = lower.replaceAll(RegExp(r'[a-z]'), '');
    final unit = lower.replaceAll(RegExp(r'\d'), '').trim();
    final num = int.tryParse(numStr) ?? 30;
    switch (unit) {
      case 'm':
      case 'min':
        return '$num minutes';
      case 'h':
      case 'hr':
        return '$num hours';
      case 'd':
        return '$num days';
      default:
        return '30 minutes';
    }
  }

  String _escapeString(String value) =>
      value.replaceAll('"', '\\"').replaceAll('\\', '\\\\');
}
