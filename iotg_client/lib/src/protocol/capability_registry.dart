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

/// The capability registry — the only schema the agent runtime can see.
/// Stored as a JSON snapshot updated on every ingestion cycle.
abstract class CapabilityRegistry implements _i1.SerializableModel {
  CapabilityRegistry._({
    this.id,
    required this.registryJson,
    required this.refreshedAt,
  });

  factory CapabilityRegistry({
    int? id,
    required String registryJson,
    required DateTime refreshedAt,
  }) = _CapabilityRegistryImpl;

  factory CapabilityRegistry.fromJson(Map<String, dynamic> jsonSerialization) {
    return CapabilityRegistry(
      id: jsonSerialization['id'] as int?,
      registryJson: jsonSerialization['registryJson'] as String,
      refreshedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['refreshedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// JSON string: {entities: {pod: {metrics:[], logs:bool, anomaly_detection:bool}}}
  String registryJson;

  /// Timestamp of when this snapshot was last refreshed
  DateTime refreshedAt;

  /// Returns a shallow copy of this [CapabilityRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CapabilityRegistry copyWith({
    int? id,
    String? registryJson,
    DateTime? refreshedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CapabilityRegistry',
      if (id != null) 'id': id,
      'registryJson': registryJson,
      'refreshedAt': refreshedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CapabilityRegistryImpl extends CapabilityRegistry {
  _CapabilityRegistryImpl({
    int? id,
    required String registryJson,
    required DateTime refreshedAt,
  }) : super._(
         id: id,
         registryJson: registryJson,
         refreshedAt: refreshedAt,
       );

  /// Returns a shallow copy of this [CapabilityRegistry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CapabilityRegistry copyWith({
    Object? id = _Undefined,
    String? registryJson,
    DateTime? refreshedAt,
  }) {
    return CapabilityRegistry(
      id: id is int? ? id : this.id,
      registryJson: registryJson ?? this.registryJson,
      refreshedAt: refreshedAt ?? this.refreshedAt,
    );
  }
}
