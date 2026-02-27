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

/// A persisted record of a user observability query.
/// Used for save/replay functionality.
abstract class ObservabilityQuery implements _i1.SerializableModel {
  ObservabilityQuery._({
    this.id,
    required this.userQuery,
    required this.intentJson,
    required this.planJson,
    required this.esqlQuery,
    required this.createdAt,
  });

  factory ObservabilityQuery({
    int? id,
    required String userQuery,
    required String intentJson,
    required String planJson,
    required String esqlQuery,
    required DateTime createdAt,
  }) = _ObservabilityQueryImpl;

  factory ObservabilityQuery.fromJson(Map<String, dynamic> jsonSerialization) {
    return ObservabilityQuery(
      id: jsonSerialization['id'] as int?,
      userQuery: jsonSerialization['userQuery'] as String,
      intentJson: jsonSerialization['intentJson'] as String,
      planJson: jsonSerialization['planJson'] as String,
      esqlQuery: jsonSerialization['esqlQuery'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The raw natural-language query from the user
  String userQuery;

  /// JSON of the IntentResult from the Intent Agent
  String intentJson;

  /// JSON of the ExecutionPlan from the Planning Agent
  String planJson;

  /// The compiled ES|QL query string
  String esqlQuery;

  /// When this query was created
  DateTime createdAt;

  /// Returns a shallow copy of this [ObservabilityQuery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ObservabilityQuery copyWith({
    int? id,
    String? userQuery,
    String? intentJson,
    String? planJson,
    String? esqlQuery,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ObservabilityQuery',
      if (id != null) 'id': id,
      'userQuery': userQuery,
      'intentJson': intentJson,
      'planJson': planJson,
      'esqlQuery': esqlQuery,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ObservabilityQueryImpl extends ObservabilityQuery {
  _ObservabilityQueryImpl({
    int? id,
    required String userQuery,
    required String intentJson,
    required String planJson,
    required String esqlQuery,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userQuery: userQuery,
         intentJson: intentJson,
         planJson: planJson,
         esqlQuery: esqlQuery,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ObservabilityQuery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ObservabilityQuery copyWith({
    Object? id = _Undefined,
    String? userQuery,
    String? intentJson,
    String? planJson,
    String? esqlQuery,
    DateTime? createdAt,
  }) {
    return ObservabilityQuery(
      id: id is int? ? id : this.id,
      userQuery: userQuery ?? this.userQuery,
      intentJson: intentJson ?? this.intentJson,
      planJson: planJson ?? this.planJson,
      esqlQuery: esqlQuery ?? this.esqlQuery,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
