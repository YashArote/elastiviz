import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'elasticsearch_client.dart';
import '../generated/protocol.dart';

/// Orchestrates the full schema ingestion pipeline.
/// Runs periodically in the background — the agent runtime never calls this.
///
/// Pipeline:
///   1. discoverDatasets  → upserts DatasetRegistry rows
///   2. discoverFields    → upserts FieldRegistry rows per dataset
///   3. classifyMetrics   → upserts MetricDictionary rows (deterministic rules)
///   4. buildCapabilities → upserts CapabilityRegistry JSON snapshot
class SchemaIngestor {
  final Session _session;
  late final ElasticsearchClient _es;

  // Deterministic classification rules
  // Maps field-path substring patterns -> metric category
  static const Map<String, String> _categoryRules = {
    '.cpu.usage.pct': 'cpu',
    '.cpu.': 'cpu_raw',
    'cpu.': 'cpu_raw',
    '.memory.usage.pct': 'memory',
    '.memory.': 'memory_raw',
    'memory.': 'memory_raw',
    '.network.': 'network',
    'network.': 'network',
    '.disk.': 'disk',
    'disk.': 'disk',
    '.filesystem.': 'filesystem',
    'filesystem.': 'filesystem',
    '.load.': 'load',
    'load.': 'load',
  };

  // Maps entity type names to the entity filter field in ECS
  static const Map<String, String> _entityFilterFields = {
    'pod': 'kubernetes.pod.name',
    'node': 'kubernetes.node.name',
    'service': 'service.name',
    'container': 'kubernetes.container.name',
    'namespace': 'kubernetes.namespace',
  };

  // Maps dataset name prefixes to entity types
  static const Map<String, String> _datasetEntityMap = {
    'kubernetes.container': 'pod',
    'kubernetes.pod': 'pod',
    'kubernetes.node': 'node',
    'kubernetes.service': 'service',
    'kubernetes.namespace': 'namespace',
  };

  SchemaIngestor(this._session) {
    _es = ElasticsearchClient.fromSession(_session);
  }

  /// Run the full ingestion pipeline.
  Future<void> run() async {
    _session.log('[SchemaIngestor] Starting ingestion cycle...');
    try {
      final datasets = await discoverDatasets();
      _session.log('[SchemaIngestor] Found ${datasets.length} datasets');

      for (final dataset in datasets) {
        await discoverFields(dataset);
      }

      await classifyMetrics();
      await buildCapabilityRegistry();
      _session.log('[SchemaIngestor] Ingestion cycle complete ✓');
    } catch (e, st) {
      _session.log(
        '[SchemaIngestor] ERROR: $e\n$st',
        level: LogLevel.error,
      );
    }
  }

  // ─── Phase A1: Dataset Discovery ─────────────────────────────────────────

  Future<List<DatasetRegistry>> discoverDatasets() async {
    final now = DateTime.now().toUtc();
    final datasets = <DatasetRegistry>[];

    // Elastic Cloud Serverless does not always support SHOW DATASETS.
    // Instead, we probe the known Kubernetes data-stream patterns directly.
    final knownPatterns = <Map<String, String>>[
      {'name': 'kubernetes.container', 'type': 'metrics'},
      {'name': 'kubernetes.pod', 'type': 'metrics'},
      {'name': 'kubernetes.node', 'type': 'metrics'},
      {'name': 'kubernetes.deployment', 'type': 'metrics'},
      {'name': 'kubernetes.statefulset', 'type': 'metrics'},
      {'name': 'kubernetes.daemonset', 'type': 'metrics'},
      {'name': 'kubernetes.namespace', 'type': 'metrics'},
      {'name': 'kubernetes.volume', 'type': 'metrics'},
      {'name': 'kubernetes.system', 'type': 'metrics'},
      {'name': 'kubernetes.container', 'type': 'logs'},
    ];

    for (final pattern in knownPatterns) {
      final datasetName = pattern['name']!;
      final dataType = pattern['type']!;
      final indexPattern = dataType == 'logs'
          ? 'logs-$datasetName*'
          : 'metrics-$datasetName*';

      // Probe: does this index have any data?
      final exists = await _probeIndex(indexPattern);
      if (!exists) continue;

      // Upsert into DatasetRegistry
      final existing = await DatasetRegistry.db.findFirstRow(
        _session,
        where: (t) => t.name.equals(datasetName) & t.dataType.equals(dataType),
      );

      if (existing != null) {
        await DatasetRegistry.db.updateRow(
          _session,
          existing.copyWith(lastSeen: now),
        );
        datasets.add(existing.copyWith(lastSeen: now));
      } else {
        final saved = await DatasetRegistry.db.insertRow(
          _session,
          DatasetRegistry(
            name: datasetName,
            indexPattern: indexPattern,
            dataType: dataType,
            lastSeen: now,
          ),
        );
        datasets.add(saved);
      }
    }

    return datasets;
  }

  /// Returns true if the given index pattern has at least one document.
  Future<bool> _probeIndex(String indexPattern) async {
    try {
      // Use LIMIT 0 — just check the columns exist; doesn't fetch any rows.
      await _es.runEsqlRaw('FROM $indexPattern | LIMIT 0');
      return true;
    } catch (e) {
      // Index doesn't exist or no data — skip it silently
      return false;
    }
  }

  // ─── Phase A2: Field Discovery ───────────────────────────────────────────

  Future<void> discoverFields(DatasetRegistry dataset) async {
    final query = 'FROM ${dataset.indexPattern} | LIMIT 1';
    Map<String, dynamic> rawResponse;

    try {
      rawResponse = await _es.runEsqlRaw(query);
    } catch (e) {
      _session.log(
        '[SchemaIngestor] Field discovery failed for ${dataset.name}: $e',
        level: LogLevel.warning,
      );
      return;
    }

    final columns = (rawResponse['columns'] as List?) ?? [];
    for (final col in columns) {
      final fieldPath = (col['name'] ?? '').toString();
      final esType = (col['type'] ?? 'keyword').toString();
      if (fieldPath.isEmpty || fieldPath.startsWith('_')) continue;

      final isNumeric = _isNumericType(esType);
      final isTimeseries =
          isNumeric && fieldPath.contains('@timestamp') == false;

      final existing = await FieldRegistry.db.findFirstRow(
        _session,
        where: (t) =>
            t.dataset.equals(dataset.name) & t.fieldPath.equals(fieldPath),
      );

      if (existing == null) {
        await FieldRegistry.db.insertRow(
          _session,
          FieldRegistry(
            dataset: dataset.name,
            fieldPath: fieldPath,
            fieldType: esType,
            isNumeric: isNumeric,
            isTimeseries: isTimeseries,
          ),
        );
      }
    }
    _session.log(
      '[SchemaIngestor] Field discovery done for ${dataset.name}: ${columns.length} columns',
    );
  }

  bool _isNumericType(String esType) {
    return [
      'double',
      'long',
      'float',
      'integer',
      'short',
      'byte',
      'half_float',
      'scaled_float',
    ].contains(esType);
  }

  // ─── Phase A4: Metric Classification ────────────────────────────────────

  Future<void> classifyMetrics() async {
    // Load all numeric, timeseries fields
    final fields = await FieldRegistry.db.find(
      _session,
      where: (t) => t.isNumeric.equals(true) & t.isTimeseries.equals(true),
    );

    // Clear existing metric dictionary to rebuild
    await MetricDictionary.db.deleteWhere(
      _session,
      where: (_) => Constant.bool(true),
    );

    for (final field in fields) {
      String? category;
      for (final entry in _categoryRules.entries) {
        if (field.fieldPath.contains(entry.key)) {
          category = entry.value;
          break;
        }
      }
      if (category == null) continue;

      // Infer entity type from dataset
      String entityType = 'unknown';
      for (final entry in _datasetEntityMap.entries) {
        if (field.dataset.startsWith(entry.key)) {
          entityType = entry.value;
          break;
        }
      }
      if (entityType == 'unknown') continue;

      final unit = _inferUnit(category, field.fieldPath);
      final score = _fieldScore(field.fieldPath);

      // Keep the best-scoring field per category+entityType.
      // Prefer rate/percentage fields over raw nanosecond counters.
      final existing = await MetricDictionary.db.findFirstRow(
        _session,
        where: (t) =>
            t.category.equals(category!) & t.entityType.equals(entityType),
      );
      if (existing == null) {
        await MetricDictionary.db.insertRow(
          _session,
          MetricDictionary(
            category: category,
            entityType: entityType,
            dataset: field.dataset,
            fieldPath: field.fieldPath,
            unit: unit,
          ),
        );
      } else if (score > _fieldScore(existing.fieldPath)) {
        // Better field found — replace
        await MetricDictionary.db.deleteRow(_session, existing);
        await MetricDictionary.db.insertRow(
          _session,
          MetricDictionary(
            category: category,
            entityType: entityType,
            dataset: field.dataset,
            fieldPath: field.fieldPath,
            unit: unit,
          ),
        );
      }
    }
    _session.log('[SchemaIngestor] Metric classification done');
  }

  int _fieldScore(String fieldPath) {
    if (fieldPath.endsWith('.ns') || fieldPath.endsWith('_ns')) return 0;

    int score = 5; // Default middle score

    // Percentage fields are the high-priority default per user request
    if (fieldPath.contains('.pct') || fieldPath.contains('_pct')) {
      score += 5;
    }

    // Usage fields are the gold standard for observability
    if (fieldPath.contains('.usage') || fieldPath.contains('_usage')) {
      score += 2;
    }

    // Absolute cores/bytes are solid fallbacks
    if (fieldPath.contains('nanocores') ||
        fieldPath.contains('.bytes') ||
        fieldPath.contains('_bytes')) {
      score += 1;
    }

    // Penalize metrics that describe "free" space when the general intent is usage
    if (fieldPath.contains('available') ||
        fieldPath.contains('free') ||
        fieldPath.contains('idle')) {
      score -= 7;
    }

    return score.clamp(0, 10);
  }

  String _inferUnit(String category, String fieldPath) {
    if (category.endsWith('_pct') ||
        fieldPath.contains('.pct') ||
        fieldPath.contains('_pct'))
      return '%';
    if (fieldPath.contains('.bytes') || fieldPath.contains('_bytes'))
      return 'bytes';
    if (fieldPath.contains('.cores') || fieldPath.contains('_cores'))
      return 'cores';
    if (fieldPath.contains('.packets') || fieldPath.contains('_packets'))
      return 'packets/s';
    switch (category) {
      case 'cpu':
        return '%';
      case 'memory':
        return 'bytes';
      case 'network':
        return 'bytes/s';
      case 'disk':
        return 'bytes';
      default:
        return '';
    }
  }

  // ─── Phase A5: Capability Registry ──────────────────────────────────────

  Future<void> buildCapabilityRegistry() async {
    final metrics = await MetricDictionary.db.find(_session);

    // Build: entity -> {metrics: [], logs: bool, anomaly_detection: bool}
    final entities = <String, Map<String, dynamic>>{};
    for (final m in metrics) {
      entities.putIfAbsent(
        m.entityType,
        () => {
          'metrics': <String>[],
          'logs': m.entityType == 'node',
          'anomaly_detection': true,
          'filter_field':
              _entityFilterFields[m.entityType] ?? '${m.entityType}.name',
        },
      );
      final metricList = entities[m.entityType]!['metrics'] as List<String>;
      if (!metricList.contains(m.category)) {
        metricList.add(m.category);
      }
    }

    final registryJson = jsonEncode({'entities': entities});
    final now = DateTime.now().toUtc();

    // Only keep one row — update if exists
    final existing = await CapabilityRegistry.db.findFirstRow(_session);
    if (existing != null) {
      await CapabilityRegistry.db.updateRow(
        _session,
        existing.copyWith(registryJson: registryJson, refreshedAt: now),
      );
    } else {
      await CapabilityRegistry.db.insertRow(
        _session,
        CapabilityRegistry(registryJson: registryJson, refreshedAt: now),
      );
    }
    _session.log(
      '[SchemaIngestor] Capability registry updated: ${entities.keys.join(", ")}',
    );
  }
}
