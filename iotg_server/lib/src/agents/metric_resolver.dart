import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Metric Resolver — lookup only, no LLM.
/// Maps abstract metric names to concrete ECS field paths
/// via the MetricDictionary table.
class MetricResolver {
  final Session _session;

  MetricResolver(this._session);

  /// Resolves metric category names for a given entity type.
  /// Returns a list of [ResolvedMetric] descriptors.
  Future<List<ResolvedMetric>> resolve(
    List<String> categories,
    String entityType,
  ) async {
    final results = <ResolvedMetric>[];

    for (final category in categories) {
      // Primary lookup: exact entity + category match
      var row = await MetricDictionary.db.findFirstRow(
        _session,
        where: (t) =>
            t.category.equals(category) & t.entityType.equals(entityType),
      );

      // Fallback: any entity with this category
      row ??= await MetricDictionary.db.findFirstRow(
        _session,
        where: (t) => t.category.equals(category),
      );

      if (row != null) {
        results.add(
          ResolvedMetric(
            category: category,
            dataset: row.dataset,
            fieldPath: row.fieldPath,
            unit: row.unit,
            displayName: _displayName(category),
          ),
        );
      }
    }

    return results;
  }

  String _displayName(String category) {
    const names = {
      'cpu': 'CPU Usage',
      'memory': 'Memory Usage',
      'network': 'Network Usage',
      'disk': 'Disk Usage',
      'filesystem': 'Filesystem Usage',
      'load': 'System Load',
    };
    return names[category] ??
        '${category[0].toUpperCase()}${category.substring(1)}';
  }
}

/// A metric concept resolved to a concrete ECS field.
class ResolvedMetric {
  final String category;
  final String dataset;
  final String fieldPath;
  final String unit;
  final String displayName;

  const ResolvedMetric({
    required this.category,
    required this.dataset,
    required this.fieldPath,
    required this.unit,
    required this.displayName,
  });

  Map<String, dynamic> toMap() => {
    'category': category,
    'dataset': dataset,
    'fieldPath': fieldPath,
    'unit': unit,
    'displayName': displayName,
  };
}
