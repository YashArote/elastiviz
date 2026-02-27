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

/// A single entry in the generated metric dictionary.
/// Maps an abstract metric concept (e.g. "cpu") to an ECS field path.
abstract class MetricDictionary implements _i1.SerializableModel {
  MetricDictionary._({
    this.id,
    required this.category,
    required this.entityType,
    required this.dataset,
    required this.fieldPath,
    required this.unit,
  });

  factory MetricDictionary({
    int? id,
    required String category,
    required String entityType,
    required String dataset,
    required String fieldPath,
    required String unit,
  }) = _MetricDictionaryImpl;

  factory MetricDictionary.fromJson(Map<String, dynamic> jsonSerialization) {
    return MetricDictionary(
      id: jsonSerialization['id'] as int?,
      category: jsonSerialization['category'] as String,
      entityType: jsonSerialization['entityType'] as String,
      dataset: jsonSerialization['dataset'] as String,
      fieldPath: jsonSerialization['fieldPath'] as String,
      unit: jsonSerialization['unit'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Abstract metric category: cpu, memory, network, disk, etc.
  String category;

  /// Entity type this metric applies to: pod, node, service
  String entityType;

  /// The source dataset (e.g. "kubernetes.container")
  String dataset;

  /// The full ECS field path
  String fieldPath;

  /// Measurement unit: %, bytes, cores, etc.
  String unit;

  /// Returns a shallow copy of this [MetricDictionary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MetricDictionary copyWith({
    int? id,
    String? category,
    String? entityType,
    String? dataset,
    String? fieldPath,
    String? unit,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MetricDictionary',
      if (id != null) 'id': id,
      'category': category,
      'entityType': entityType,
      'dataset': dataset,
      'fieldPath': fieldPath,
      'unit': unit,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MetricDictionaryImpl extends MetricDictionary {
  _MetricDictionaryImpl({
    int? id,
    required String category,
    required String entityType,
    required String dataset,
    required String fieldPath,
    required String unit,
  }) : super._(
         id: id,
         category: category,
         entityType: entityType,
         dataset: dataset,
         fieldPath: fieldPath,
         unit: unit,
       );

  /// Returns a shallow copy of this [MetricDictionary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MetricDictionary copyWith({
    Object? id = _Undefined,
    String? category,
    String? entityType,
    String? dataset,
    String? fieldPath,
    String? unit,
  }) {
    return MetricDictionary(
      id: id is int? ? id : this.id,
      category: category ?? this.category,
      entityType: entityType ?? this.entityType,
      dataset: dataset ?? this.dataset,
      fieldPath: fieldPath ?? this.fieldPath,
      unit: unit ?? this.unit,
    );
  }
}
