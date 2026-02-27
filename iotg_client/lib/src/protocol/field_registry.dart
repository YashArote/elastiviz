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

/// Raw ECS field discovered in a specific dataset.
abstract class FieldRegistry implements _i1.SerializableModel {
  FieldRegistry._({
    this.id,
    required this.dataset,
    required this.fieldPath,
    required this.fieldType,
    required this.isNumeric,
    required this.isTimeseries,
  });

  factory FieldRegistry({
    int? id,
    required String dataset,
    required String fieldPath,
    required String fieldType,
    required bool isNumeric,
    required bool isTimeseries,
  }) = _FieldRegistryImpl;

  factory FieldRegistry.fromJson(Map<String, dynamic> jsonSerialization) {
    return FieldRegistry(
      id: jsonSerialization['id'] as int?,
      dataset: jsonSerialization['dataset'] as String,
      fieldPath: jsonSerialization['fieldPath'] as String,
      fieldType: jsonSerialization['fieldType'] as String,
      isNumeric: jsonSerialization['isNumeric'] as bool,
      isTimeseries: jsonSerialization['isTimeseries'] as bool,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The dataset this field belongs to (e.g. "kubernetes.container")
  String dataset;

  /// The full ECS field path (e.g. "kubernetes.container.cpu.usage.node.pct")
  String fieldPath;

  /// Elasticsearch data type (double, long, keyword, date, etc.)
  String fieldType;

  /// Whether this field is numeric (double / long / float)
  bool isNumeric;

  /// Whether this field is suitable for timeseries charting
  bool isTimeseries;

  /// Returns a shallow copy of this [FieldRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FieldRegistry copyWith({
    int? id,
    String? dataset,
    String? fieldPath,
    String? fieldType,
    bool? isNumeric,
    bool? isTimeseries,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FieldRegistry',
      if (id != null) 'id': id,
      'dataset': dataset,
      'fieldPath': fieldPath,
      'fieldType': fieldType,
      'isNumeric': isNumeric,
      'isTimeseries': isTimeseries,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FieldRegistryImpl extends FieldRegistry {
  _FieldRegistryImpl({
    int? id,
    required String dataset,
    required String fieldPath,
    required String fieldType,
    required bool isNumeric,
    required bool isTimeseries,
  }) : super._(
         id: id,
         dataset: dataset,
         fieldPath: fieldPath,
         fieldType: fieldType,
         isNumeric: isNumeric,
         isTimeseries: isTimeseries,
       );

  /// Returns a shallow copy of this [FieldRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FieldRegistry copyWith({
    Object? id = _Undefined,
    String? dataset,
    String? fieldPath,
    String? fieldType,
    bool? isNumeric,
    bool? isTimeseries,
  }) {
    return FieldRegistry(
      id: id is int? ? id : this.id,
      dataset: dataset ?? this.dataset,
      fieldPath: fieldPath ?? this.fieldPath,
      fieldType: fieldType ?? this.fieldType,
      isNumeric: isNumeric ?? this.isNumeric,
      isTimeseries: isTimeseries ?? this.isTimeseries,
    );
  }
}
