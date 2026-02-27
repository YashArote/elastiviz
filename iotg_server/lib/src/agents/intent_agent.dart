import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// Intent Agent — extracts structured intent from natural language.
///
/// The LLM is given ONLY:
///   - The user's raw query
///   - Entity names and their available metric names from the capability registry
///
/// The LLM NEVER sees: ECS field paths, index names, datasets, ES|QL syntax.
class IntentAgent {
  final Session _session;

  IntentAgent(this._session);

  /// Parses [userQuery] into a structured intent map:
  /// {goal, entity_type, entity_name, metrics[], time_window}
  Future<Map<String, dynamic>> parse(
    String userQuery,
    Map<String, dynamic> capabilityRegistry,
  ) async {
    final apiKey =
        _session.passwords['geminiApiKey'] ?? 'PLACEHOLDER_GEMINI_API_KEY';
    final entitySummary = _buildEntitySummary(capabilityRegistry);
    final entityNames =
        (capabilityRegistry['entities'] as Map<String, dynamic>? ?? {}).keys
            .join(', ');

    final systemPrompt =
        '''You are a Kubernetes observability intent parser.
Your task is to extract a structured JSON object from the user's monitoring query.

Available entities and their observable metrics:
$entitySummary

Output ONLY a valid JSON object — no explanation, no markdown, no code blocks:
{
  "goal": "<visualize_metrics | detect_anomalies | compare_metrics>",
  "entity_type": "<one of: $entityNames>",
  "entity_name": "<the specific resource name mentioned in the query>",
  "metrics": ["<metric1>", "<metric2>"],
  "time_window": "<duration string like 30m, 1h, 6h, 24h>"
}

Rules:
- Pick entity_type from the available list only
- Metrics must only use names from that entity's available list
- Default time_window to "30m" if not mentioned
- If multiple resources mentioned, pick the primary one
- Output the JSON object ONLY''';

    final responseText = await _callGemini(
      apiKey,
      systemPrompt,
      'User query: "$userQuery"',
    );

    final jsonStr = _extractJson(responseText);
    final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
    _sanitize(parsed, capabilityRegistry);
    return parsed;
  }

  String _buildEntitySummary(Map<String, dynamic> registry) {
    final entities = registry['entities'] as Map<String, dynamic>? ?? {};
    final sb = StringBuffer();
    for (final e in entities.entries) {
      final caps = e.value as Map<String, dynamic>;
      final metrics = (caps['metrics'] as List?)?.join(', ') ?? '';
      sb.writeln('- ${e.key}: metrics=[${metrics}]');
    }
    return sb.toString().trim();
  }

  void _sanitize(
    Map<String, dynamic> result,
    Map<String, dynamic> registry,
  ) {
    // Fill defaults
    result.putIfAbsent('time_window', () => '30m');
    result.putIfAbsent('goal', () => 'visualize_metrics');
    result.putIfAbsent('metrics', () => []);
    result.putIfAbsent('entity_name', () => 'unknown');

    // Validate entity type — fall back to first available
    final entities = registry['entities'] as Map<String, dynamic>? ?? {};
    if (!entities.containsKey(result['entity_type'])) {
      result['entity_type'] = entities.keys.isNotEmpty
          ? entities.keys.first
          : 'pod';
    }

    // Filter metrics to only valid ones for this entity
    final entityType = result['entity_type'] as String;
    final available =
        ((entities[entityType] as Map?)?['metrics'] as List?)?.cast<String>() ??
        [];
    final requested = (result['metrics'] as List?)?.cast<String>() ?? [];
    final filtered = requested.where(available.contains).toList();
    result['metrics'] = filtered.isEmpty
        ? available.take(2).toList()
        : filtered;
  }

  Future<String> _callGemini(
    String apiKey,
    String systemPrompt,
    String userMessage,
  ) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userMessage},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.05,
        'maxOutputTokens': 300,
      },
    });

    final response = await http.post(
      uri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error [${response.statusCode}]: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = (data['candidates'] as List?) ?? [];
    if (candidates.isEmpty) throw Exception('Gemini returned no candidates');
    final parts = (candidates.first['content']['parts'] as List?) ?? [];
    if (parts.isEmpty) throw Exception('Gemini returned empty parts');
    return parts.first['text'] as String;
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw FormatException('No JSON object found in LLM response:\n$text');
    }
    return text.substring(start, end + 1);
  }
}
