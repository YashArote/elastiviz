import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Planning Agent — pure rule-based, no LLM.
/// Validates the intent against the CapabilityRegistry and produces
/// a typed execution plan.
class PlanningAgent {
  final Session _session;

  PlanningAgent(this._session);

  /// Returns an execution plan map:
  /// {dataset, metrics[], entity_filter{field,value}, time_window,
  ///  post_processing[], entity_type, entity_name}
  ///
  /// Throws [PlanningError] if intent cannot be satisfied.
  Future<Map<String, dynamic>> plan(Map<String, dynamic> intent) async {
    final capRow = await CapabilityRegistry.db.findFirstRow(_session);
    if (capRow == null) {
      throw PlanningError(
        'Capability registry is empty. Schema ingestion has not completed yet. '
        'Please wait a moment and try again.',
      );
    }

    final registry = jsonDecode(capRow.registryJson) as Map<String, dynamic>;
    final entities = registry['entities'] as Map<String, dynamic>? ?? {};

    final entityType = (intent['entity_type'] ?? 'pod') as String;
    final entityName = (intent['entity_name'] ?? 'unknown') as String;
    final requestedMetrics = (intent['metrics'] as List? ?? []).cast<String>();
    final timeWindow = (intent['time_window'] ?? '30m') as String;

    if (!entities.containsKey(entityType)) {
      throw PlanningError(
        'Entity type "$entityType" is not available. '
        'Supported entities: ${entities.keys.join(", ")}.',
      );
    }

    final caps = entities[entityType] as Map<String, dynamic>;
    final available = (caps['metrics'] as List? ?? []).cast<String>();

    final resolvedMetrics = requestedMetrics.where(available.contains).toList();

    if (resolvedMetrics.isEmpty) {
      throw PlanningError(
        'No matching metrics for entity "$entityType". '
        'Requested: $requestedMetrics. Available: $available.',
      );
    }

    // Resolve the primary dataset from MetricDictionary
    final firstMetricRow = await MetricDictionary.db.findFirstRow(
      _session,
      where: (t) =>
          t.entityType.equals(entityType) &
          t.category.equals(resolvedMetrics.first),
    );
    if (firstMetricRow == null) {
      throw PlanningError(
        'Metric dictionary has no entry for '
        '$entityType/${resolvedMetrics.first}. '
        'Schema ingestion may not have completed.',
      );
    }

    final filterField =
        caps['filter_field'] as String? ?? 'kubernetes.$entityType.name';

    final postProcessing = <String>[];
    if (caps['anomaly_detection'] == true) {
      postProcessing.add('anomaly_detection');
    }
    postProcessing.add('explanation');

    return {
      'dataset': firstMetricRow.dataset,
      'metrics': resolvedMetrics,
      'entity_filter': {
        'field': filterField,
        'value': entityName,
      },
      'time_window': timeWindow,
      'post_processing': postProcessing,
      'entity_type': entityType,
      'entity_name': entityName,
    };
  }
}

class PlanningError implements Exception {
  final String message;
  PlanningError(this.message);
  @override
  String toString() => 'PlanningError: $message';
}
