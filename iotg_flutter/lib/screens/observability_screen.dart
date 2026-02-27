import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/observability_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/conversation_history_drawer.dart';

/// Main observability screen — a chat-driven interface for querying
/// Kubernetes metrics via natural language, backed by the Elastic Agent
/// Builder + Gemini pipeline.
class ObservabilityScreen extends StatefulWidget {
  const ObservabilityScreen({super.key});

  @override
  State<ObservabilityScreen> createState() => _ObservabilityScreenState();
}

class _ObservabilityScreenState extends State<ObservabilityScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Quick-access example queries matching current backend capabilities
  static const _exampleQueries = [
    'Show top 3 pods consuming maximum CPU last 4 days',
    'Show memory usage of pod noisy over last 20 days',
    'Show CPU usage of top 3 pods over last 20 days',
  ];

  // Capability chips shown in the landing hero
  static const _capabilities = [
    ('Elastic Agent', Icons.memory_rounded, Color(0xFF0066FF)),
    ('ES|QL', Icons.code_rounded, Color(0xFF7B61FF)),
    ('Kubernetes', Icons.hub_rounded, Color(0xFF00FFA3)),
    ('MCP', Icons.lan_outlined, Color(0xFFFFB800)),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ObservabilityProvider>(
      builder: (context, prov, _) => PopScope(
        // Allow normal back (exit/previous route) only when on landing screen.
        // If there are messages, back goes to landing (clears chat) with auto-save.
        canPop: prov.messages.isEmpty,
        onPopInvoked: (didPop) {
          if (!didPop) {
            // Auto-save already happened after each response. Just clear UI.
            prov.newConversation(clearMessages: true);
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFF060F1E),
          drawer: const ConversationHistoryDrawer(),
          appBar: _buildAppBar(),
          body: Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF080F1E),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        tooltip: 'Conversation history',
        icon: const Icon(Icons.menu_rounded, color: Colors.white70),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Elastiviz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Elastic Agent Builder',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // New conversation
        Consumer<ObservabilityProvider>(
          builder: (_, prov, __) => IconButton(
            tooltip: 'New conversation',
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white54),
            onPressed: () => _confirmNewConversation(prov),
          ),
        ),
        // Schema refresh
        Consumer<ObservabilityProvider>(
          builder: (_, prov, __) => IconButton(
            tooltip: 'Refresh schema',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white38),
            onPressed: () async {
              await prov.refreshSchema();
              if (context.mounted && prov.schemaStatus != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(prov.schemaStatus!),
                    backgroundColor: const Color(0xFF1E2D40),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Colors.white10),
      ),
    );
  }

  // ── Message list ────────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    return Consumer<ObservabilityProvider>(
      builder: (_, prov, __) {
        final messages = prov.messages;

        if (messages.isEmpty) {
          return _buildWelcomeScreen();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: messages.length,
          itemBuilder: (_, i) => ChatBubble(message: messages[i]),
        );
      },
    );
  }

  // ── Welcome / landing screen ───────────────────────────────────────────────

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero ─────────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                // Logo placeholder — swap in Image.asset('assets/logo.png') later
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/logo_name.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ask anything about your infrastructure',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Natural language → Elastic Agent Builder → ES|QL → Live metrics',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Capability chips
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: _capabilities
                      .map((cap) => _capabilityChip(cap.$1, cap.$2, cap.$3))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Example queries ───────────────────────────────────────────────
          const Text(
            'Try asking:',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._exampleQueries.map((q) => _exampleQueryChip(q)),

          const SizedBox(height: 24),

          // ── How it works ──────────────────────────────────────────────────
        ],
      ),
    );
  }

  Widget _capabilityChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pipelineStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title  ',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: desc,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exampleQueryChip(String query) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          _controller.text = query;
          _focusNode.requestFocus();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.18),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 15,
                color: Color(0xFF00D4FF),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  query,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Input area ─────────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    return Consumer<ObservabilityProvider>(
      builder: (context, prov, _) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF080F1E),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? const Color(0xFF00D4FF).withOpacity(0.5)
                            : Colors.white12,
                        width: _focusNode.hasFocus ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.search_rounded,
                          color: Colors.white38,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: !prov.isQuerying,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Ask about your Kubernetes metrics...',
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            maxLines: 3,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(prov),
                          ),
                        ),
                        // Clear button
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _controller.clear()),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.white38,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _sendButton(prov),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sendButton(ObservabilityProvider prov) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: prov.isQuerying
            ? null
            : const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: prov.isQuerying ? const Color(0xFF1E2D40) : null,
        boxShadow: prov.isQuerying
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: IconButton(
        icon: prov.isQuerying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF00D4FF),
                ),
              )
            : const Icon(Icons.send_rounded, size: 20, color: Colors.white),
        onPressed: prov.isQuerying ? null : () => _send(prov),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _send(ObservabilityProvider prov) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();
    setState(() {}); // refresh clear button
    prov.sendQuery(text);
  }

  /// Conversation is auto-saved after every response — just start fresh.
  void _confirmNewConversation(ObservabilityProvider prov) {
    if (prov.messages.isEmpty) return;
    prov.newConversation(clearMessages: true);
  }
}
