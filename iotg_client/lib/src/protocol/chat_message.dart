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

/// A single response message returned from the observability pipeline.
/// Used as the wire format to Flutter.
abstract class ChatResponse implements _i1.SerializableModel {
  ChatResponse._({
    required this.status,
    required this.explanation,
    this.chartJson,
    this.queryId,
    this.conversationId,
  });

  factory ChatResponse({
    required String status,
    required String explanation,
    String? chartJson,
    int? queryId,
    String? conversationId,
  }) = _ChatResponseImpl;

  factory ChatResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatResponse(
      status: jsonSerialization['status'] as String,
      explanation: jsonSerialization['explanation'] as String,
      chartJson: jsonSerialization['chartJson'] as String?,
      queryId: jsonSerialization['queryId'] as int?,
      conversationId: jsonSerialization['conversationId'] as String?,
    );
  }

  /// "success" or "error"
  String status;

  /// The natural language explanation (or error message)
  String explanation;

  /// JSON-encoded ChartData (may be null if error or no data)
  String? chartJson;

  /// Query ID for replay (null if not persisted)
  int? queryId;

  /// Elastic Agent Builder conversation ID — pass back on next query
  /// for multi-turn memory (remembers entity, prior context etc.)
  String? conversationId;

  /// Returns a shallow copy of this [ChatResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatResponse copyWith({
    String? status,
    String? explanation,
    String? chartJson,
    int? queryId,
    String? conversationId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatResponse',
      'status': status,
      'explanation': explanation,
      if (chartJson != null) 'chartJson': chartJson,
      if (queryId != null) 'queryId': queryId,
      if (conversationId != null) 'conversationId': conversationId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatResponseImpl extends ChatResponse {
  _ChatResponseImpl({
    required String status,
    required String explanation,
    String? chartJson,
    int? queryId,
    String? conversationId,
  }) : super._(
         status: status,
         explanation: explanation,
         chartJson: chartJson,
         queryId: queryId,
         conversationId: conversationId,
       );

  /// Returns a shallow copy of this [ChatResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatResponse copyWith({
    String? status,
    String? explanation,
    Object? chartJson = _Undefined,
    Object? queryId = _Undefined,
    Object? conversationId = _Undefined,
  }) {
    return ChatResponse(
      status: status ?? this.status,
      explanation: explanation ?? this.explanation,
      chartJson: chartJson is String? ? chartJson : this.chartJson,
      queryId: queryId is int? ? queryId : this.queryId,
      conversationId: conversationId is String?
          ? conversationId
          : this.conversationId,
    );
  }
}
