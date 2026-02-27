import 'package:serverpod/serverpod.dart';
import '../schema/schema_ingestor.dart';

/// Serverpod FutureCall that periodically triggers schema ingestion.
/// Self-reschedules every 15 minutes after each successful run.
class SchemaRefreshCall extends FutureCall<SerializableException> {
  static const String callName = 'schemaRefresh';
  static const Duration refreshInterval = Duration(minutes: 15);

  @override
  Future<void> invoke(
    Session session,
    SerializableException? object,
  ) async {
    session.log('[SchemaRefreshCall] Starting scheduled ingestion cycle...');
    try {
      await SchemaIngestor(session).run();
    } catch (e, st) {
      session.log(
        '[SchemaRefreshCall] Ingestion failed: $e\n$st',
        level: LogLevel.error,
      );
    }

    // Reschedule for next run
    await session.serverpod.futureCallWithDelay(
      callName,
      null,
      refreshInterval,
    );
  }
}
