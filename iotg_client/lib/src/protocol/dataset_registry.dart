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

/// Represents a discovered Elasticsearch data stream / dataset.
abstract class DatasetRegistry implements _i1.SerializableModel {
  DatasetRegistry._({
    this.id,
    required this.name,
    required this.indexPattern,
    required this.dataType,
    required this.lastSeen,
  });

  factory DatasetRegistry({
    int? id,
    required String name,
    required String indexPattern,
    required String dataType,
    required DateTime lastSeen,
  }) = _DatasetRegistryImpl;

  factory DatasetRegistry.fromJson(Map<String, dynamic> jsonSerialization) {
    return DatasetRegistry(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      indexPattern: jsonSerialization['indexPattern'] as String,
      dataType: jsonSerialization['dataType'] as String,
      lastSeen: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastSeen'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The dataset name, e.g. "kubernetes.container"
  String name;

  /// The index pattern used to query, e.g. "metrics-kubernetes.container*"
  String indexPattern;

  /// Either "metrics" or "logs"
  String dataType;

  /// Timestamp of the last successful discovery
  DateTime lastSeen;

  /// Returns a shallow copy of this [DatasetRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DatasetRegistry copyWith({
    int? id,
    String? name,
    String? indexPattern,
    String? dataType,
    DateTime? lastSeen,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DatasetRegistry',
      if (id != null) 'id': id,
      'name': name,
      'indexPattern': indexPattern,
      'dataType': dataType,
      'lastSeen': lastSeen.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DatasetRegistryImpl extends DatasetRegistry {
  _DatasetRegistryImpl({
    int? id,
    required String name,
    required String indexPattern,
    required String dataType,
    required DateTime lastSeen,
  }) : super._(
         id: id,
         name: name,
         indexPattern: indexPattern,
         dataType: dataType,
         lastSeen: lastSeen,
       );

  /// Returns a shallow copy of this [DatasetRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DatasetRegistry copyWith({
    Object? id = _Undefined,
    String? name,
    String? indexPattern,
    String? dataType,
    DateTime? lastSeen,
  }) {
    return DatasetRegistry(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      indexPattern: indexPattern ?? this.indexPattern,
      dataType: dataType ?? this.dataType,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
