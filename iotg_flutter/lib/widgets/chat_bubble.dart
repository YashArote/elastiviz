import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/observability_provider.dart';
import 'chart_card.dart';

/// A single message bubble in the chat thread.
/// User messages appear right-aligned in electric blue.
/// Bot responses appear left-aligned in dark navy, optionally containing a chart.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: message.isUser ? _userBubble() : _botBubble(),
    );
  }

  Widget _userBubble() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const SizedBox(width: 56),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      _avatar(isUser: true),
    ],
  );

  Widget _botBubble() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _avatar(isUser: false),
      const SizedBox(width: 8),
      Flexible(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: message.isError
                  ? const Color(0xFFFF4B4B).withOpacity(0.4)
                  : Colors.white10,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: message.isLoading ? _loadingIndicator() : _botContent(),
        ),
      ),
      const SizedBox(width: 56),
    ],
  );

  Widget _botContent() {
    if (message.isError) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4B4B), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.text,
              style: const TextStyle(
                color: Color(0xFFFF8A8A),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart
        if (message.chart != null) ...[
          ChartCard(
            chart: message.chart!,
            explanation: message.explanation ?? '',
          ),
        ] else if (message.explanation != null &&
            message.explanation!.isNotEmpty) ...[
          // Text-only explanation
          Text(
            message.explanation!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ] else ...[
          Text(
            message.text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
        // Timestamp + query ID
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
            if (message.queryId != null)
              Text(
                'Saved #${message.queryId}',
                style: const TextStyle(color: Colors.white24, fontSize: 10),
              ),
          ],
        ),
      ],
    );
  }

  Widget _loadingIndicator() => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF00D4FF),
        ),
      ),
      SizedBox(width: 10),
      Text(
        'Analyzing...',
        style: TextStyle(color: Colors.white54, fontSize: 13),
      ),
    ],
  );

  Widget _avatar({required bool isUser}) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: isUser
            ? [const Color(0xFF0066FF), const Color(0xFF00D4FF)]
            : [const Color(0xFF1E2D40), const Color(0xFF2A3F58)],
      ),
      border: Border.all(color: Colors.white10),
    ),
    child: Icon(
      isUser ? Icons.person_outline : Icons.auto_awesome,
      size: 16,
      color: isUser ? Colors.white : const Color(0xFF00D4FF),
    ),
  );
}
