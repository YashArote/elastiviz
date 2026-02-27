import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

/// Low-level client for Elasticsearch Cloud (Serverless) REST API.
/// Uses ES|QL via the /_query HTTP endpoint with API Key authentication.
class ElasticsearchClient {
  final String _baseUrl;
  final String _apiKey;

  ElasticsearchClient({required String baseUrl, required String apiKey})
    : _baseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl,
      _apiKey = apiKey;

  /// Factory that reads credentials from Serverpod session passwords.
  factory ElasticsearchClient.fromSession(Session session) {
    // URL read from environment or config placeholder
    final url = const String.fromEnvironment(
      'ES_URL',
      defaultValue:
          'https://my-observability-project-cb9415.es.us-central1.gcp.elastic.cloud',
    );
    final apiKey =
        session.passwords['elasticsearchApiKey'] ??
        'REMOVED_SECRET==';
    return ElasticsearchClient(baseUrl: url, apiKey: apiKey);
  }

  /// Singleton persistent HTTP client — reuses TCP+TLS connection across
  /// ES|QL requests, avoiding the ~200-300ms TLS handshake on every call.
  static final http.Client _httpClient = http.Client();

  Map<String, String> get _headers => {
    HttpHeaders.authorizationHeader: 'ApiKey $_apiKey',
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
    'X-Elastic-Product-Origin': 'observability',
  };

  /// Executes an ES|QL query and returns rows as a list of column->value maps.
  Future<List<Map<String, dynamic>>> runEsql(String esql) async {
    final raw = await runEsqlRaw(esql);
    return _parseTabular(raw);
  }

  /// Executes an ES|QL query and returns the raw JSON response.
  /// Useful for field introspection via column metadata.
  Future<Map<String, dynamic>> runEsqlRaw(String esql) async {
    final uri = Uri.parse('$_baseUrl/_query');
    // Note: 'format' must NOT be in the body for Elastic Cloud Serverless.
    // JSON is the default; we request it explicitly via the Accept header.
    final body = jsonEncode({'query': esql});

    final response = await _httpClient.post(uri, headers: _headers, body: body);
    if (response.statusCode != 200) {
      throw ElasticsearchException(
        'ES|QL failed [${response.statusCode}]: ${response.body}',
        statusCode: response.statusCode,
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _parseTabular(Map<String, dynamic> raw) {
    final columns = (raw['columns'] as List)
        .map((c) => c['name'] as String)
        .toList();
    final rows = (raw['values'] as List?) ?? [];
    return rows.map<Map<String, dynamic>>((row) {
      final cells = row as List;
      return {
        for (var i = 0; i < columns.length && i < cells.length; i++)
          columns[i]: cells[i],
      };
    }).toList();
  }
}

class ElasticsearchException implements Exception {
  final String message;
  final int statusCode;
  ElasticsearchException(this.message, {required this.statusCode});

  @override
  String toString() => 'ElasticsearchException[$statusCode]: $message';
}
