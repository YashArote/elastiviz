import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/schema/schema_refresh_call.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';
import 'src/web/routes/agent_tool_routes.dart';
import 'src/web/routes/mcp_tool_routes.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  // ── Register Schema Ingestion FutureCall ──────────────────────────────────
  pod.registerFutureCall(SchemaRefreshCall(), SchemaRefreshCall.callName);

  // ── Web Routes ────────────────────────────────────────────────────────────
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // ── Elastic Agent Builder Tool Webhook Routes ─────────────────────────────
  // These are called by Kibana Agent Builder when the agent executes a tool.
  // Configure each tool in Kibana with: POST https://<your-server>/tools/<name>
  pod.webServer.addRoute(
    CapabilityRegistryRoute(),
    '/tools/capability-registry',
  );
  pod.webServer.addRoute(ValidatePlanRoute(), '/tools/validate-plan');
  pod.webServer.addRoute(CompileEsqlRoute(), '/tools/compile-esql');
  pod.webServer.addRoute(RunEsqlRoute(), '/tools/run-esql');

  // ── MCP (Model Context Protocol) Streamable HTTP endpoint ────────────────
  // Single POST /mcp endpoint implementing JSON-RPC 2.0 over Streamable HTTP.
  // Compatible with any MCP client (Claude Desktop, Cursor, VS Code, etc.).
  pod.webServer.addRoute(McpToolRoute(), '/mcp');
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    pod.webServer.addRoute(
      FlutterRoute(Directory(Uri(path: 'web/app').toFilePath())),
      '/app',
    );
  } else {
    pod.webServer.addRoute(
      StaticRoute.file(
        File(Uri(path: 'web/pages/build_flutter_app.html').toFilePath()),
      ),
      '/app/**',
    );
  }

  // ── Start Server ──────────────────────────────────────────────────────────
  await pod.start();

  // ── Kickoff first schema ingestion immediately on startup ─────────────────
  pod.futureCallWithDelay(
    SchemaRefreshCall.callName,
    null,
    const Duration(seconds: 5), // Short delay to let server fully start
  );
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}
