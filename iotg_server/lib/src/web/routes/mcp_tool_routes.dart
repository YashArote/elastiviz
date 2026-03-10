import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';
import '../../schema/elasticsearch_client.dart';
import '../../agents/agent_result_cache.dart';
import '../../esql/esql_compiler.dart';

/// MCP (Model Context Protocol) endpoint — Streamable HTTP transport.
///
/// Implements the 2025-03-26 MCP spec over a single POST /mcp route.
/// Every request is a JSON-RPC 2.0 envelope; responses are returned as
/// application/json (non-streaming). Notifications (id==null) return 202.
///
/// Supported JSON-RPC methods:
///   initialize            — handshake / capability negotiation
///   notifications/initialized — client ack (no response needed)
///   tools/list            — enumerate available tools + input schemas
///   tools/call            — invoke a tool by name
///
/// Tools exposed (same logic as agent_tool_routes.dart):
///   capability_registry   — fetch the ES capability registry from DB
///   validate_plan         — validate entity/metric plan and resolve fields
///   compile_esql          — build an ES|QL query string from field paths
///   run_esql              — execute ES|QL against Elasticsearch and return rows
///
/// Register in server.dart:
///   pod.webServer.addRoute(McpToolRoute(), '/mcp');
class McpToolRoute extends Route {
  McpToolRoute() : super(methods: {Method.post});

  // ── MCP protocol constants ────────────────────────────────────────────────

  static const String _protocolVersion = '2025-03-26';
  static const String _serverName = 'iotg-observability';
  static const String _serverVersion = '1.0.0';

  // ── In-memory cache for capability registry ──────────────────────────────
  // The registry only changes when SchemaIngestor runs (every 1h).
  // Caching for 10 min avoids a DB round-trip on every agent query.
  static Map<String, dynamic>? _registryCache;
  static DateTime? _registryCacheTime;
  static const _registryCacheTtl = Duration(minutes: 10);

  Future<Map<String, dynamic>?> _getRegistry(Session session) async {
    final now = DateTime.now();
    if (_registryCache != null &&
        _registryCacheTime != null &&
        now.difference(_registryCacheTime!) < _registryCacheTtl) {
      return _registryCache;
    }
    final row = await CapabilityRegistry.db.findFirstRow(session);
    if (row == null) return null;
    _registryCache = jsonDecode(row.registryJson) as Map<String, dynamic>;
    _registryCacheTime = now;
    return _registryCache;
  }

  static const Map<String, String> _entityFilterFields = {
    'pod': 'kubernetes.pod.name',
    'node': 'kubernetes.node.name',
    'service': 'service.name',
    'container': 'kubernetes.container.name',
    'namespace': 'kubernetes.namespace',
  };

  // ── Entry point ───────────────────────────────────────────────────────────

  @override
  Future<Response> handleCall(Session session, Request request) async {
    // MCP Streamable HTTP: only POST is valid.
    if (request.method != Method.post) {
      return _errorResponse(
        405,
        null,
        -32600,
        'Method Not Allowed — MCP requires POST',
      );
    }

    // Parse the JSON-RPC body.
    final rawBody = await _readBody(request);
    if (rawBody == null) {
      return _errorResponse(400, null, -32700, 'Parse error: invalid JSON');
    }

    // MCP allows batch (array) or single (object) requests.
    // We handle single objects only for simplicity.
    if (rawBody is! Map<String, dynamic>) {
      return _errorResponse(400, null, -32600, 'Batch requests not supported');
    }

    final envelope = rawBody;
    final id = envelope['id']; // may be null (notification), int, or string
    final method = envelope['method'] as String?;
    final params =
        envelope['params'] as Map<String, dynamic>? ?? <String, dynamic>{};

    if (method == null) {
      return _errorResponse(400, id, -32600, 'Missing "method" field');
    }

    // Notifications (id == null) — just ack with 202.
    if (id == null) {
      return Response(202, body: Body.fromString(''));
    }

    try {
      return switch (method) {
        'initialize' => _handleInitialize(id, params),
        'notifications/initialized' => Response(202, body: Body.fromString('')),
        'tools/list' => _handleToolsList(id),
        'tools/call' => await _handleToolsCall(session, id, params),
        _ => _errorResponse(
          200,
          id,
          -32601,
          'Method not found: $method',
        ),
      };
    } catch (e) {
      session.log(
        '[McpToolRoute] Unhandled error in $method: $e',
        level: LogLevel.error,
      );
      return _errorResponse(200, id, -32603, 'Internal error: $e');
    }
  }

  // ── initialize ────────────────────────────────────────────────────────────

  Response _handleInitialize(Object? id, Map<String, dynamic> params) {
    return _ok(id, {
      'protocolVersion': _protocolVersion,
      'capabilities': {
        'tools': {'listChanged': false},
      },
      'serverInfo': {'name': _serverName, 'version': _serverVersion},
    });
  }

  // ── tools/list ────────────────────────────────────────────────────────────

  Response _handleToolsList(Object? id) {
    return _ok(id, {
      'tools': [
        {
          'name': 'capability_registry',
          'description':
              '''Returns all observable entity types (pod, node, namespace, service, container) 
and their available metric categories. Call this first before any other tool. 
No inputs required.''',
          'inputSchema': {
            'type': 'object',
            'properties': <String, dynamic>{},
            'required': <String>[],
          },
        },
        {
          'name': 'validate_plan',
          'description': '''
Validates intent and resolves exact ECS field paths and index patterns.
Inputs: entity_type (string), entity_name (string), metrics (string[]), time_window (string, optional).
Returns: index_pattern, entity_filter {field, value}, field_paths[], dataset.
If valid=false, stop and return an error to the user.''',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'entity_type': {
                'type': 'string',
                'description':
                    'e.g. "pod", "node", "service", "container", "namespace"',
              },
              'entity_name': {
                'type': 'string',
                'description': 'Exact name of the entity to filter on.',
              },
              'metrics': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'List of metric categories to request.',
              },
              'time_window': {
                'type': 'string',
                'description':
                    'Look-back window, e.g. "30m", "1h". Default: "30m".',
              },
            },
            'required': ['entity_type', 'entity_name', 'metrics'],
          },
        },
        {
          'name': 'compile_esql',
          'description': '''
Builds a deterministic ES|QL query string. Do NOT write ES|QL yourself.
Inputs: index_pattern, entity_filter_field, entity_filter_value, metric_field_paths (string[]), time_window.
Use exact values returned by validate_plan — do not modify them.
Returns: { "esql": "FROM ... | WHERE ... | KEEP ... | SORT ... | LIMIT 1000" }
''',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'index_pattern': {
                'type': 'string',
                'description':
                    'Elasticsearch index pattern, e.g. "metrics-kubernetes.pod*".',
              },
              'entity_filter_field': {
                'type': 'string',
                'description':
                    'ECS field to filter on, e.g. "kubernetes.pod.name".',
              },
              'entity_filter_value': {
                'type': 'string',
                'description': 'Value to match for the filter field.',
              },
              'metric_field_paths': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'ECS field paths to select, e.g. ["kubernetes.pod.cpu.usage.node.pct"].',
              },
              'time_window': {
                'type': 'string',
                'description': 'Look-back window, e.g. "30m". Default: "30m".',
              },
            },
            'required': [
              'index_pattern',
              'entity_filter_field',
              'metric_field_paths',
            ],
          },
        },
        {
          'name': 'run_esql',
          'description':
              'Executes an ES|QL query against Elasticsearch and returns the '
              'rows as a JSON array of column→value maps.',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'esql': {
                'type': 'string',
                'description':
                    '''Executes the ES|QL query against Elasticsearch and returns all data rows.
Input: esql (string) — use the EXACT string from compile_esql, character for character.
Returns: { "rows": [...], "count": N }.
''',
              },
            },
            'required': ['esql'],
          },
        },
        /*{
          'name': 'search_logs',
          'description':
              'Searches container/pod log lines in Elasticsearch. '
              'Use this (NOT validate_plan + run_esql) when the user asks about '
              'errors, crashes, warnings, events, log messages, or any text-based '
              'query. Returns matching log lines with timestamp, pod, and message.',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'entity_type': {
                'type': 'string',
                'description': 'e.g. "pod", "container", "node"',
              },
              'entity_name': {
                'type': 'string',
                'description':
                    'Exact pod/container name to filter on. Use "*" for all.',
              },
              'keywords': {
                'type': 'array',
                'items': {'type': 'string'},
                'description':
                    'Keywords to search in the log message, e.g. ["error", "OOMKilled"].',
              },
              'log_level': {
                'type': 'string',
                'description':
                    'Optional log level filter: "error", "warn", "info". Omit for all levels.',
              },
              'time_window': {
                'type': 'string',
                'description':
                    'Look-back window, e.g. "1h", "12h". Default: "1h".',
              },
              'limit': {
                'type': 'integer',
                'description': 'Max log lines to return. Default: 50.',
              },
            },
            'required': ['entity_type', 'entity_name', 'keywords'],
          },
        },*/
      ],
    });
  }

  // ── tools/call ────────────────────────────────────────────────────────────

  Future<Response> _handleToolsCall(
    Session session,
    Object? id,
    Map<String, dynamic> params,
  ) async {
    final toolName = params['name'] as String?;
    final args =
        params['arguments'] as Map<String, dynamic>? ?? <String, dynamic>{};

    if (toolName == null) {
      return _errorResponse(200, id, -32602, 'Missing "name" in params');
    }

    return switch (toolName) {
      'capability_registry' => await _toolCapabilityRegistry(session, id),
      'validate_plan' => await _toolValidatePlan(session, id, args),
      'compile_esql' => _toolCompileEsql(session, id, args),
      'run_esql' => await _toolRunEsql(session, id, args),
      'search_logs' => await _toolSearchLogs(session, id, args),
      _ => _errorResponse(200, id, -32602, 'Unknown tool: $toolName'),
    };
  }

  // ── Tool implementations ──────────────────────────────────────────────────

  /// capability_registry — same logic as CapabilityRegistryRoute.handleCall()
  Future<Response> _toolCapabilityRegistry(Session session, Object? id) async {
    final registry = await _getRegistry(session);
    if (registry == null) {
      return _toolError(
        id,
        'Capability registry not ready. Schema ingestion pending.',
      );
    }
    return _toolSuccess(id, registry);
  }

  /// validate_plan — same logic as ValidatePlanRoute.handleCall()
  Future<Response> _toolValidatePlan(
    Session session,
    Object? id,
    Map<String, dynamic> args,
  ) async {
    final entityType = (args['entity_type'] as String? ?? '').toLowerCase();
    final entityName = args['entity_name'] as String? ?? '';
    final metrics = (args['metrics'] as List? ?? []).cast<String>();
    final timeWindow = args['time_window'] as String? ?? '30m';

    // Use cached registry to avoid an extra DB round-trip
    final registry = await _getRegistry(session);
    if (registry == null) {
      return _toolError(id, 'Capability registry not ready');
    }

    final entities = registry['entities'] as Map<String, dynamic>? ?? {};

    if (!entities.containsKey(entityType)) {
      return _toolError(
        id,
        'Unknown entity_type "$entityType". '
        'Available: ${entities.keys.join(", ")}',
      );
    }

    final caps = entities[entityType] as Map<String, dynamic>;
    final available = (caps['metrics'] as List).cast<String>();
    final resolvedMetrics = metrics.where(available.contains).toList();

    if (resolvedMetrics.isEmpty) {
      return _toolError(
        id,
        'None of $metrics available for $entityType. Available: $available',
      );
    }

    final fieldPaths = <String>[];
    String? dataset;
    // Single batched DB read for all metrics — replaces N sequential reads.
    final allMetricRows = await MetricDictionary.db.find(
      session,
      where: (t) => t.entityType.equals(entityType),
    );

    // Build metric map with preference: prefer absolute fields (nanocores, bytes)
    // over percentage (.pct) fields — pct fields are 0 when resource limits are
    // not set in Kubernetes, which is common in dev clusters.
    final metricMap = <String, MetricDictionary>{};
    for (final r in allMetricRows) {
      final existing = metricMap[r.category];
      if (existing == null) {
        metricMap[r.category] = r;
      } else {
        // Keep whichever field is more "absolute":
        // nanocores > non-pct > .pct (last resort)
        final isPctNew = r.fieldPath.contains('.pct');
        final isPctOld = existing.fieldPath.contains('.pct');
        final isNanoCoresNew = r.fieldPath.contains('nanocores');
        final isNanoCoresOld = existing.fieldPath.contains('nanocores');
        if (isNanoCoresNew && !isNanoCoresOld) {
          metricMap[r.category] = r; // always prefer nanocores
        } else if (!isPctNew && isPctOld) {
          metricMap[r.category] = r; // prefer absolute over pct
        }
        // else keep existing (it's already better or equivalent)
      }
    }

    for (final metric in resolvedMetrics) {
      final row = metricMap[metric];
      if (row != null) {
        fieldPaths.add(row.fieldPath);
        dataset ??= row.dataset;
      }
    }

    if (fieldPaths.isEmpty || dataset == null) {
      return _toolError(
        id,
        'No fields in MetricDictionary for $entityType/$resolvedMetrics',
      );
    }

    final filterField =
        _entityFilterFields[entityType] ??
        caps['filter_field'] as String? ??
        'kubernetes.$entityType.name';
    final indexPattern = dataset.contains('log')
        ? 'logs-$dataset*'
        : 'metrics-$dataset*';

    return _toolSuccess(id, {
      'valid': true,
      'dataset': dataset,
      'index_pattern': indexPattern,
      'entity_filter': {'field': filterField, 'value': entityName},
      'metrics': resolvedMetrics,
      'field_paths': fieldPaths,
      'time_window': timeWindow,
    });
  }

  /// compile_esql — same logic as CompileEsqlRoute.handleCall()
  Response _toolCompileEsql(
    Session session,
    Object? id,
    Map<String, dynamic> args,
  ) {
    final indexPattern = args['index_pattern'] as String? ?? '';
    final filterField = args['entity_filter_field'] as String? ?? '';
    final filterValue = args['entity_filter_value'] as String? ?? '';
    final fieldPaths = (args['metric_field_paths'] as List? ?? [])
        .cast<String>();
    final timeWindow = args['time_window'] as String? ?? '30m';

    if (indexPattern.isEmpty || filterField.isEmpty || fieldPaths.isEmpty) {
      return _toolError(
        id,
        'Missing required arguments: '
        'index_pattern, entity_filter_field, metric_field_paths',
      );
    }

    final esql = EsqlCompiler().buildFromFields(
      indexPattern: indexPattern,
      filterField: filterField,
      filterValue: filterValue,
      fieldPaths: fieldPaths,
      timeWindow: timeWindow,
    );

    session.log(
      '[McpToolRoute/compile_esql] OK: ${esql.substring(0, esql.length.clamp(0, 80))}...',
    );
    return _toolSuccess(id, {'esql': esql});
  }

  /// search_logs — full-text search over container/pod log lines.
  /// Routes to logs-kubernetes.container* instead of metrics-*.
  Future<Response> _toolSearchLogs(
    Session session,
    Object? id,
    Map<String, dynamic> args,
  ) async {
    final entityName = args['entity_name'] as String? ?? '*';
    final keywords = (args['keywords'] as List? ?? []).cast<String>();
    final logLevel = args['log_level'] as String?;
    final timeWindow = args['time_window'] as String? ?? '1h';
    final limit = (args['limit'] as int?) ?? 50;

    if (keywords.isEmpty) {
      return _toolError(id, 'At least one keyword is required');
    }

    // Build ES|QL against logs-kubernetes.container*
    // Log lines have: @timestamp, message, log.level,
    //                 kubernetes.pod.name, kubernetes.container.name
    final lines = <String>[
      'FROM logs-kubernetes.container*',
      '| WHERE @timestamp > NOW() - $timeWindow',
    ];

    // Entity filter (skip if wildcard)
    if (entityName != '*' && entityName.isNotEmpty) {
      lines.add('| WHERE kubernetes.pod.name == "$entityName"');
    }

    // Keyword filters — each keyword must appear in the message
    for (final kw in keywords) {
      lines.add('| WHERE message LIKE "%$kw%"');
    }

    // Optional log level filter
    if (logLevel != null && logLevel.isNotEmpty) {
      lines.add('| WHERE log.level == "$logLevel"');
    }

    lines.addAll([
      '| KEEP @timestamp, kubernetes.pod.name, kubernetes.container.name, log.level, message',
      '| SORT @timestamp DESC',
      '| LIMIT $limit',
    ]);

    final esql = lines.join('\n');
    session.log(
      '[McpToolRoute/search_logs] Query: ${esql.substring(0, esql.length.clamp(0, 120))}...',
    );

    try {
      final client = ElasticsearchClient.fromSession(session);
      final rows = await client.runEsql(esql);
      session.log(
        '[McpToolRoute/search_logs] ${rows.length} log lines returned',
      );
      return _toolSuccess(id, {
        'log_lines': rows,
        'count': rows.length,
        'index': 'logs-kubernetes.container*',
        'query_keywords': keywords,
      });
    } catch (e) {
      // Likely no logs index exists yet — return a clear message
      session.log(
        '[McpToolRoute/search_logs] Error: $e',
        level: LogLevel.warning,
      );
      return _toolError(
        id,
        'Log search failed: $e. '
        'Ensure the Elastic Agent is forwarding container logs '
        'to logs-kubernetes.container*.',
      );
    }
  }

  /// run_esql — same logic as RunEsqlRoute.handleCall()
  Future<Response> _toolRunEsql(
    Session session,
    Object? id,
    Map<String, dynamic> args,
  ) async {
    final esql = args['esql'] as String? ?? '';
    if (esql.isEmpty) {
      return _toolError(id, 'esql is required');
    }
    final client = ElasticsearchClient.fromSession(session);
    final rows = await client.runEsql(esql);
    session.log('[McpToolRoute/run_esql] ${rows.length} rows returned');

    // Cap rows sent to the agent: 1000 raw rows blows the LLM context window.
    // Downsample to ≤300 evenly-spaced rows; the pipeline still gets full data
    // via the agent's final JSON, which re-embeds only these sampled rows.
    // Cache the result for "REF:LAST_RUN" optimization
    if (esql.isNotEmpty) {
      AgentResultCache.store(esql, rows);
    }

    return _toolSuccess(id, {
      'rows': rows,
      'count': rows.length,
      'sampled': rows.length,
    });
  }

  // ── JSON-RPC response helpers ─────────────────────────────────────────────

  /// Successful JSON-RPC result — wraps [data] in the MCP CallToolResult
  /// content envelope so MCP clients get properly typed content.
  Response _toolSuccess(Object? id, Map<String, dynamic> data) {
    return _ok(id, {
      'content': [
        {'type': 'text', 'text': jsonEncode(data)},
      ],
      'isError': false,
    });
  }

  /// Tool-level error (tool ran but returned an error state).
  /// We return HTTP 200 + isError:true per MCP spec.
  Response _toolError(Object? id, String message) {
    return _ok(id, {
      'content': [
        {'type': 'text', 'text': message},
      ],
      'isError': true,
    });
  }

  /// Successful JSON-RPC response envelope.
  Response _ok(Object? id, Map<String, dynamic> result) {
    return Response(
      200,
      body: Body.fromString(
        jsonEncode({'jsonrpc': '2.0', 'id': id, 'result': result}),
        mimeType: MimeType.json,
      ),
    );
  }

  /// JSON-RPC error response envelope.
  Response _errorResponse(
    int httpStatus,
    Object? id,
    int code,
    String message,
  ) {
    return Response(
      httpStatus,
      body: Body.fromString(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'error': {'code': code, 'message': message},
        }),
        mimeType: MimeType.json,
      ),
    );
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  Future<Object?> _readBody(Request request) async {
    try {
      final raw = await request.readAsString();
      if (raw.isEmpty) return null;
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }
}
