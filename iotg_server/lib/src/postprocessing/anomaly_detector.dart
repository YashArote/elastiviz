import 'dart:math';
import '../generated/protocol.dart';
import '../agents/metric_resolver.dart';

/// Anomaly Detector — math-only, no ML or LLM.
///
/// Techniques used:
///   1. Rolling Z-Score (window=10): flags when |z| > 2.5 (medium) or > 3.5 (high)
///   2. Spike Detection: consecutive delta > 3× rolling standard deviation
///
/// Returns a list of [AnomalyEntry] objects with timestamps, severity, and reason.
class AnomalyDetector {
  static const int _zScoreWindow = 10;
  static const double _zScoreMedThreshold = 2.5;
  static const double _zScoreHighThreshold = 3.5;
  static const double _spikeMultiplier = 3.0;

  /// Detects anomalies across all metrics in the rows.
  /// [fieldPaths] — ECS field path strings (e.g. "kubernetes.container.cpu.usage.node.pct")
  /// Used by the new Elastic Agent Builder pipeline.
  List<AnomalyEntry> detectFromRows(
    List<Map<String, dynamic>> rows,
    List<String> fieldPaths,
  ) {
    final anomalies = <AnomalyEntry>[];
    for (final fieldPath in fieldPaths) {
      final label = _labelFromPath(fieldPath);
      final series = _extractSeries(rows, fieldPath);
      if (series.length < 3) continue;
      final values = series.map((p) => p.value).toList();
      final timestamps = series.map((p) => p.timestamp).toList();
      anomalies.addAll(_detectZScore(values, timestamps, label));
      anomalies.addAll(_detectSpikes(values, timestamps, label));
    }
    return _deduplicate(anomalies);
  }

  String _labelFromPath(String path) {
    // "kubernetes.container.cpu.usage.node.pct" → "cpu"
    const known = ['cpu', 'memory', 'network', 'disk', 'load', 'filesystem'];
    for (final k in known) {
      if (path.contains(k)) return k;
    }
    return path.split('.').last;
  }

  /// Legacy: detects anomalies using ResolvedMetric list (old pipeline).
  List<AnomalyEntry> detect(
    List<Map<String, dynamic>> rows,
    List<ResolvedMetric> metrics,
  ) {
    final anomalies = <AnomalyEntry>[];

    for (final metric in metrics) {
      final series = _extractSeries(rows, metric.fieldPath);
      if (series.length < 3) continue;

      final values = series.map((p) => p.value).toList();
      final timestamps = series.map((p) => p.timestamp).toList();

      anomalies.addAll(
        _detectZScore(values, timestamps, metric.category),
      );
      anomalies.addAll(
        _detectSpikes(values, timestamps, metric.category),
      );
    }

    return _deduplicate(anomalies);
  }

  List<_DataPoint> _extractSeries(
    List<Map<String, dynamic>> rows,
    String fieldPath,
  ) {
    final points = <_DataPoint>[];
    for (final row in rows) {
      final ts = row['@timestamp']?.toString();
      final val = row[fieldPath];
      if (ts == null || val == null) continue;
      final num? numVal = val is num ? val : double.tryParse(val.toString());
      if (numVal == null) continue;
      points.add(_DataPoint(ts, numVal.toDouble()));
    }
    return points;
  }

  List<AnomalyEntry> _detectZScore(
    List<double> values,
    List<String> timestamps,
    String metric,
  ) {
    final anomalies = <AnomalyEntry>[];
    for (var i = _zScoreWindow; i < values.length; i++) {
      final window = values.sublist(i - _zScoreWindow, i);
      final mean = _mean(window);
      final std = _std(window, mean);
      if (std < 1e-10) continue; // constant window

      final z = (values[i] - mean) / std;
      final absZ = z.abs();

      if (absZ >= _zScoreHighThreshold) {
        anomalies.add(
          AnomalyEntry(
            timestamp: timestamps[i],
            metric: metric,
            severity: 'high',
            reason: 'z-score ${absZ.toStringAsFixed(1)}',
          ),
        );
      } else if (absZ >= _zScoreMedThreshold) {
        anomalies.add(
          AnomalyEntry(
            timestamp: timestamps[i],
            metric: metric,
            severity: 'medium',
            reason: 'z-score ${absZ.toStringAsFixed(1)}',
          ),
        );
      }
    }
    return anomalies;
  }

  List<AnomalyEntry> _detectSpikes(
    List<double> values,
    List<String> timestamps,
    String metric,
  ) {
    final anomalies = <AnomalyEntry>[];
    if (values.length < 4) return anomalies;

    for (var i = _zScoreWindow; i < values.length; i++) {
      final window = values.sublist(i - _zScoreWindow, i);
      final rollingStd = _std(window, _mean(window));
      if (rollingStd < 1e-10) continue;

      final delta = (values[i] - values[i - 1]).abs();
      if (delta > _spikeMultiplier * rollingStd) {
        anomalies.add(
          AnomalyEntry(
            timestamp: timestamps[i],
            metric: metric,
            severity: delta > 5 * rollingStd ? 'high' : 'medium',
            reason:
                'spike Δ${delta.toStringAsFixed(2)} > ${_spikeMultiplier}× σ(${rollingStd.toStringAsFixed(2)})',
          ),
        );
      }
    }
    return anomalies;
  }

  double _mean(List<double> values) =>
      values.fold(0.0, (a, b) => a + b) / values.length;

  double _std(List<double> values, double mean) {
    final variance =
        values
            .map((v) => pow(v - mean, 2).toDouble())
            .fold(0.0, (a, b) => a + b) /
        values.length;
    return sqrt(variance);
  }

  List<AnomalyEntry> _deduplicate(List<AnomalyEntry> anomalies) {
    final seen = <String, AnomalyEntry>{};
    for (final a in anomalies) {
      final key = '${a.timestamp}:${a.metric}';
      final existing = seen[key];
      if (existing == null || _severity(a) > _severity(existing)) {
        seen[key] = a;
      }
    }
    return seen.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  int _severity(AnomalyEntry a) {
    switch (a.severity) {
      case 'high':
        return 2;
      case 'medium':
        return 1;
      default:
        return 0;
    }
  }
}

class _DataPoint {
  final String timestamp;
  final double value;
  const _DataPoint(this.timestamp, this.value);
}
