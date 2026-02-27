/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A single math-detected anomaly point within a metric timeseries.
abstract class AnomalyEntry implements _i1.SerializableModel {
  AnomalyEntry._({
    required this.timestamp,
    required this.metric,
    required this.severity,
    required this.reason,
  });

  factory AnomalyEntry({
    required String timestamp,
    required String metric,
    required String severity,
    required String reason,
  }) = _AnomalyEntryImpl;

  factory AnomalyEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return AnomalyEntry(
      timestamp: jsonSerialization['timestamp'] as String,
      metric: jsonSerialization['metric'] as String,
      severity: jsonSerialization['severity'] as String,
      reason: jsonSerialization['reason'] as String,
    );
  }

  /// ISO8601 timestamp of the anomaly
  String timestamp;

  /// The metric concept (cpu, memory, etc.)
  String metric;

  /// Severity: low, medium, high
  String severity;

  /// Human-readable reason (e.g. "z-score 3.7")
  String reason;

  /// Returns a shallow copy of this [AnomalyEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AnomalyEntry copyWith({
    String? timestamp,
    String? metric,
    String? severity,
    String? reason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AnomalyEntry',
      'timestamp': timestamp,
      'metric': metric,
      'severity': severity,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AnomalyEntryImpl extends AnomalyEntry {
  _AnomalyEntryImpl({
    required String timestamp,
    required String metric,
    required String severity,
    required String reason,
  }) : super._(
         timestamp: timestamp,
         metric: metric,
         severity: severity,
         reason: reason,
       );

  /// Returns a shallow copy of this [AnomalyEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AnomalyEntry copyWith({
    String? timestamp,
    String? metric,
    String? severity,
    String? reason,
  }) {
    return AnomalyEntry(
      timestamp: timestamp ?? this.timestamp,
      metric: metric ?? this.metric,
      severity: severity ?? this.severity,
      reason: reason ?? this.reason,
    );
  }
}
