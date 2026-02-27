import 'dart:async';

/// Thread-safe in-memory cache for agent tool results.
///
/// The Agent Builder in Kibana calls run_esql (Tool 4). Instead of the agent
/// re-emitting the entire row set in its final JSON response (which adds
/// 10-20s of token generation time), it returns "REF:LAST_RUN".
///
/// The ObservabilityPipeline use the conversation_id to retrieve the rows
/// from this cache.
class AgentResultCache {
  /// Maps ESQL query string -> List of rows
  static final Map<String, List<Map<String, dynamic>>> _cache = {};

  static Timer? _cleanupTimer;

  static void store(String esql, List<Map<String, dynamic>> rows) {
    if (esql.isEmpty) return;
    // We trim to handle minor whitening differences
    _cache[esql.trim()] = rows;
    _ensureCleanup();
  }

  static List<Map<String, dynamic>>? retrieve(String esql) {
    return _cache[esql.trim()];
  }

  static void _ensureCleanup() {
    _cleanupTimer ??= Timer.periodic(const Duration(minutes: 30), (_) {
      // Clear cache if it gets too big to prevent memory issues
      if (_cache.length > 500) {
        _cache.clear();
      }
    });
  }
}
