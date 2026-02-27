import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../observability/observability_pipeline.dart';
import '../schema/schema_ingestor.dart';

/// Serverpod endpoint exposing the observability pipeline to the Flutter client.
class ObservabilityEndpoint extends Endpoint {
  /// Run the full agentic pipeline for a natural language [userQuery].
  /// [conversationId] — pass the ID from the previous response to continue
  /// a multi-turn conversation. Null for a new conversation.
  Future<ChatResponse> query(
    Session session,
    String userQuery, {
    String? conversationId,
  }) async {
    if (userQuery.trim().isEmpty) {
      return ChatResponse(
        status: 'error',
        explanation: 'Please enter a question about your infrastructure.',
        chartJson: null,
        queryId: null,
      );
    }
    return ObservabilityPipeline(session).run(
      userQuery.trim(),
      conversationId: conversationId,
    );
  }

  /// Returns the last 50 saved queries for history/replay UI.
  Future<List<ObservabilityQuery>> getHistory(Session session) async {
    return ObservabilityQuery.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: 50,
    );
  }

  /// Fetches a saved result by query ID for replay.
  Future<ObservabilityResult?> getResult(Session session, int queryId) async {
    return ObservabilityResult.db.findFirstRow(
      session,
      where: (t) => t.queryId.equals(queryId),
    );
  }

  /// Manually triggers a schema ingestion refresh.
  /// Useful during development / first-run setup.
  Future<String> refreshSchema(Session session) async {
    try {
      await SchemaIngestor(session).run();
      return 'Schema refresh completed successfully ✓';
    } catch (e) {
      session.log(
        '[ObservabilityEndpoint] Schema refresh failed: $e',
        level: LogLevel.error,
      );
      return 'Schema refresh failed: $e';
    }
  }
}
