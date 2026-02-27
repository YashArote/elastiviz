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

/// Persisted result for a saved observability query.
abstract class ObservabilityResult implements _i1.SerializableModel {
  ObservabilityResult._({
    this.id,
    required this.queryId,
    required this.chartJson,
    required this.explanation,
    required this.hasAnomalies,
    required this.createdAt,
  });

  factory ObservabilityResult({
    int? id,
    required int queryId,
    required String chartJson,
    required String explanation,
    required bool hasAnomalies,
    required DateTime createdAt,
  }) = _ObservabilityResultImpl;

  factory ObservabilityResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ObservabilityResult(
      id: jsonSerialization['id'] as int?,
      queryId: jsonSerialization['queryId'] as int,
      chartJson: jsonSerialization['chartJson'] as String,
      explanation: jsonSerialization['explanation'] as String,
      hasAnomalies: jsonSerialization['hasAnomalies'] as bool,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// FK to the ObservabilityQuery that produced this result
  int queryId;

  /// Full chart response JSON (series, anomalies)
  String chartJson;

  /// Plain text explanation from the Explanation Agent
  String explanation;

  /// Whether anomalies were detected
  bool hasAnomalies;

  /// When this result was stored
  DateTime createdAt;

  /// Returns a shallow copy of this [ObservabilityResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ObservabilityResult copyWith({
    int? id,
    int? queryId,
    String? chartJson,
    String? explanation,
    bool? hasAnomalies,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ObservabilityResult',
      if (id != null) 'id': id,
      'queryId': queryId,
      'chartJson': chartJson,
      'explanation': explanation,
      'hasAnomalies': hasAnomalies,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservabilityResultImpl extends ObservabilityResult {
  _ObservabilityResultImpl({
    int? id,
    required int queryId,
    required String chartJson,
    required String explanation,
    required bool hasAnomalies,
    required DateTime createdAt,
  }) : super._(
         id: id,
         queryId: queryId,
         chartJson: chartJson,
         explanation: explanation,
         hasAnomalies: hasAnomalies,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ObservabilityResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ObservabilityResult copyWith({
    Object? id = _Undefined,
    int? queryId,
    String? chartJson,
    String? explanation,
    bool? hasAnomalies,
    DateTime? createdAt,
  }) {
    return ObservabilityResult(
      id: id is int? ? id : this.id,
      queryId: queryId ?? this.queryId,
      chartJson: chartJson ?? this.chartJson,
      explanation: explanation ?? this.explanation,
      hasAnomalies: hasAnomalies ?? this.hasAnomalies,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
