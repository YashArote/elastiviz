import 'package:serverpod/serverpod.dart';
import '../schema/elasticsearch_client.dart';

/// Execution Agent — runs a compiled ES|QL query against Elasticsearch
/// and returns the raw tabular results.
class ExecutionAgent {
  final Session _session;

  ExecutionAgent(this._session);

  /// Runs [esql] and returns a list of row maps.
  /// Each map: {@timestamp -> value, field_path -> value, ...}
  Future<List<Map<String, dynamic>>> execute(String esql) async {
    _session.log('[ExecutionAgent] Running ES|QL:\n$esql');

    final client = ElasticsearchClient.fromSession(_session);
    try {
      final rows = await client.runEsql(esql);
      _session.log('[ExecutionAgent] Returned ${rows.length} rows');
      return rows;
    } on ElasticsearchException catch (e) {
      _session.log(
        '[ExecutionAgent] Query failed: $e',
        level: LogLevel.error,
      );
      rethrow;
    }
  }
}
