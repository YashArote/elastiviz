import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/observability_provider.dart';

/// Slide-in drawer listing all saved conversations.
/// Tap a conversation to load it.
/// Delete via the three-dot menu on each card (like ChatGPT).
class ConversationHistoryDrawer extends StatelessWidget {
  const ConversationHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF080F1E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1, color: Colors.white10),
            Expanded(child: _buildList(context)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'IG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'IoTG Observability',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          // + button — auto-saves current conversation then starts fresh
          Consumer<ObservabilityProvider>(
            builder: (_, prov, __) => IconButton(
              tooltip: 'New conversation',
              icon: const Icon(Icons.add_comment_outlined, size: 20),
              color: const Color(0xFF00D4FF),
              onPressed: () async {
                // Close drawer first, then start new (avoids deactivated context)
                Navigator.of(context).pop();
                await prov.newConversation(clearMessages: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    return Consumer<ObservabilityProvider>(
      builder: (_, prov, __) {
        final conversations = prov.savedConversations;
        if (conversations.isEmpty) return _buildEmpty();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: conversations.length,
          itemBuilder: (_, i) => _buildTile(context, prov, conversations[i]),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history_rounded, size: 48, color: Colors.white12),
          const SizedBox(height: 12),
          const Text(
            'No saved conversations',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Start a new chat to begin',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Conversation tile with three-dot delete ────────────────────────────────

  Widget _buildTile(
    BuildContext context,
    ObservabilityProvider prov,
    SavedConversation conv,
  ) {
    final dateStr = _formatDate(conv.createdAt);
    final msgCount = conv.messages.length;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        prov.loadConversation(conv);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          color: Colors.white.withOpacity(0.03),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chat icon
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15,
                color: Color(0xFF00D4FF),
              ),
            ),
            const SizedBox(width: 10),
            // Title + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const _Dot(),
                      const SizedBox(width: 6),
                      Text(
                        '$msgCount msg${msgCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Three-dot delete menu — only delete available (like ChatGPT)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: Colors.white38,
              ),
              color: const Color(0xFF0D1B2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.white12),
              ),
              onSelected: (value) {
                if (value == 'delete') prov.deleteConversation(conv.id);
              },
              itemBuilder: (_) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFFF4B4B),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Color(0xFFFF4B4B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEEE').format(dt);
    return DateFormat('MMM d').format(dt);
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
    width: 3,
    height: 3,
    decoration: const BoxDecoration(
      color: Colors.white24,
      shape: BoxShape.circle,
    ),
  );
}
