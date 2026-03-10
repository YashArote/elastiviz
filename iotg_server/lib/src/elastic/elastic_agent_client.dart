import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// Calls the Elastic Agent Builder Kibana API.
///
/// The agent in Kibana is pre-configured with:
///   - System prompt (observability instructions)
///   - 4 tools (webhook URLs pointing to Serverpod /tools/* routes)
///   - LLM inference endpoint
///
/// Serverpod just sends the user's natural language query and receives
/// the final structured JSON response. All tool orchestration (tool calls,
/// results, multi-step reasoning) happens on Elastic Cloud.
///
/// Multi-turn memory: pass [conversationId] from previous turns so the
/// agent remembers prior context (which pod was discussed, what was asked, etc.)
class ElasticAgentClient {
  final Session _session;

  ElasticAgentClient(this._session);

  String get _agentId {
    final id = _session.passwords['agentId'] ?? '';
    if (id.isEmpty) {
      _session.log(
        'WARNING: agentId is not set in passwords.yaml',
        level: LogLevel.warning,
      );
    }
    return id;
  }

  String get _kibanaUrl {
    final url = _session.passwords['kibanaUrl'] ?? '';
    if (url.isEmpty) {
      _session.log(
        'WARNING: kibanaUrl is not set in passwords.yaml',
        level: LogLevel.warning,
      );
    }
    return url;
  }

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Sends a natural language query to the Elastic Agent Builder.
  ///
  /// [conversationId] — pass the ID from the previous response to maintain
  /// multi-turn context. Null for a new conversation.
  ///
  /// Returns a map with keys:
  ///   output          — agent's structured JSON string response
  ///   conversation_id — persist this for follow-up queries
  Future<AgentResponse> chat(String userQuery, {String? conversationId}) async {
    final apiKey =
        _session.passwords['kibanaApiKey'] ??
        'dEhyNGdKd0I2ekxOLUNfNER5R086M2N3OVpxZUlCdWo4NkZYV2xKYTBiUQ==';

    final uri = Uri.parse('$_kibanaUrl/api/agent_builder/converse');

    final body = <String, dynamic>{
      'input': userQuery,
      'agent_id': _agentId,
    };
    // Include conversation_id for multi-turn memory (Agent Builder persists it)
    if (conversationId != null && conversationId.isNotEmpty) {
      body['conversation_id'] = conversationId;
    }

    _session.log(
      '[AgentBuilder] POST $uri — agent=$_agentId, conversation=$conversationId',
    );

    final response = await http
        .post(
          uri,
          headers: {
            HttpHeaders.authorizationHeader: 'ApiKey $apiKey',
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: 'application/json',
            'kbn-xsrf': 'true', // Required by Kibana for mutating API calls
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(minutes: 4),
          onTimeout: () => throw TimeoutException(
            'Elastic Agent Builder did not respond within 4 minutes. '
            'The agent loop may be stuck or Elastic Cloud is overloaded.',
          ),
        );

    _session.log('[AgentBuilder] Response status: ${response.statusCode}');

    if (response.statusCode == 404 && conversationId != null) {
      _session.log(
        '[AgentBuilder] WARNING: Conversation $conversationId not found (404). '
        'It was likely deleted in Kibana. Retrying as a fresh conversation.',
        level: LogLevel.warning,
      );
      // Recursively retry once without the broken conversation ID
      return chat(userQuery, conversationId: null);
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Elastic Agent Builder error [${response.statusCode}]: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Try multiple possible field names — Agent Builder API may use any of these
    final outputRaw = _extractOutput(data);
    final returnedConversationId =
        (data['conversation_id'] ?? data['conversationId'] ?? data['id'] ?? '')
            .toString();

    _session.log('[AgentBuilder] Parsed output: $outputRaw');
    _session.log('[AgentBuilder] ConversationId: $returnedConversationId');
    _session.log('[AgentBuilder] Top-level keys: ${data.keys.toList()}');

    // Three possible response shapes from Agent Builder:
    //   1. Normal: outputRaw is non-empty JSON string → parse it
    //   2. Direct: agent returned JSON as root body (no wrapper field) → use data directly
    //   3. Empty: agent failed silently → return diagnostic error
    Map<String, dynamic> parsed;
    if (outputRaw.isNotEmpty) {
      parsed = _parseAgentOutput(outputRaw);
    } else if (data.containsKey('status') && data.containsKey('rows')) {
      _session.log('[AgentBuilder] Using root body as agent response directly');
      parsed = data;
    } else {
      _session.log(
        '[AgentBuilder] WARNING: Empty output. Full body: ${response.body}',
        level: LogLevel.warning,
      );
      parsed = {
        'status': 'error',
        'error_message':
            'Agent returned an empty response. This usually happens when '
            'run_esql returned 0 rows and the agent deviated from the JSON format. '
            'Try specifying a longer time window.',
        'rows': [],
      };
    }

    return AgentResponse(
      data: parsed,
      conversationId: returnedConversationId,
    );
  }

  /// Tries every known field name the Agent Builder might use for the reply text.
  String _extractOutput(Map<String, dynamic> data) {
    // Direct string fields
    for (final key in [
      'output',
      'message',
      'response',
      'content',
      'text',
      'answer',
      'result',
    ]) {
      final v = data[key];
      if (v is String && v.isNotEmpty) return v;
    }
    // Nested: data['message']['content'] or data['output']['text'] etc.
    for (final key in ['message', 'output', 'response']) {
      final v = data[key];
      if (v is Map) {
        final inner = v['content'] ?? v['text'] ?? v['message'] ?? '';
        if (inner is String && inner.isNotEmpty) return inner;
      }
      // List of message objects
      if (v is List && v.isNotEmpty) {
        final last = v.last;
        if (last is Map) {
          final inner =
              last['content'] ?? last['text'] ?? last['message'] ?? '';
          if (inner is String && inner.isNotEmpty) return inner;
        }
      }
    }
    // Last resort: entire body as a string so we can see it
    return '';
  }

  /// Fetches conversation history from Agent Builder.
  /// Can be used for replay/history features.
  Future<List<Map<String, dynamic>>> getConversations() async {
    final apiKey = _session.passwords['kibanaApiKey'] ?? '';
    final uri = Uri.parse('$_kibanaUrl/api/agent_builder/conversations');
    final response = await http.get(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'ApiKey $apiKey',
        HttpHeaders.acceptHeader: 'application/json',
      },
    );
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ((data['conversations'] as List?) ?? [])
        .cast<Map<String, dynamic>>();
  }

  // ─── Response Parser ────────────────────────────────────────────────────────

  Map<String, dynamic> _parseAgentOutput(String output) {
    final trimmed = output.trim();

    // First, try a standard substring extraction
    int start = trimmed.indexOf('{');
    int end = trimmed.lastIndexOf('}');

    if (start != -1 && end != -1) {
      try {
        final parsed = jsonDecode(trimmed.substring(start, end + 1));
        if (parsed is Map<String, dynamic> && parsed.containsKey('status')) {
          return parsed;
        }
      } catch (_) {
        // Fall back to regex if standard parsing fails
      }
    }

    // Violent regex extraction: look for a JSON object containing "status"
    // This handles cases where Claude outputs something like:
    // "Here is the data you requested:\n```json\n{ ... }\n```\nHope this helps!"
    final jsonRegex = RegExp(
      r'\{[^{}]*"status"\s*:\s*(?:"success"|"error")[^{}]*\}',
      dotAll: true,
    );
    final match = jsonRegex.firstMatch(trimmed);

    if (match != null) {
      try {
        final parsed = jsonDecode(match.group(0)!);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
      } catch (_) {
        // Ignore and fall through to error
      }
    }

    // If we've exhausted all options, let's try an even wider regex that just looks for
    // any JSON object that looks vaguely like our schema
    final schemaRegex = RegExp(
      r'\{.*"chart_type".*"intent".*"plan".*\}',
      dotAll: true,
    );
    final schemaMatch = schemaRegex.firstMatch(trimmed);
    if (schemaMatch != null) {
      try {
        final parsed = jsonDecode(schemaMatch.group(0)!);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
      } catch (_) {
        // Ignore and fall through to error
      }
    }

    return {
      'status': 'error',
      'error_message':
          'Agent returned non-JSON response or failed to parse: $trimmed',
      'rows': [],
    };
  }
}

/// Clean return type from the Agent Builder.
class AgentResponse {
  /// Structured data parsed from the agent's JSON output.
  final Map<String, dynamic> data;

  /// Persisted conversation ID — pass back on next query for multi-turn memory.
  final String conversationId;

  const AgentResponse({required this.data, required this.conversationId});
}
