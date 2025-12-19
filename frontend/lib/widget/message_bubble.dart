import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../utils/app_colors.dart';
import '../utils/time_utils.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showStatus = false,
  });

  final ChatMessage message;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final bubbleColor = isMine ? AppColors.primary : Colors.white;
    final textColor = isMine ? Colors.white : Colors.grey.shade900;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.content,
                style: TextStyle(color: textColor, height: 1.3),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatShortTime(message.time),
                  style: TextStyle(
                    color: isMine ? Colors.white70 : Colors.grey.shade700,
                    fontSize: 11,
                  ),
                ),
                if (showStatus && isMine) ...[
                  const SizedBox(width: 6),
                  Icon(
                    _statusIcon(message.status),
                    size: 16,
                    color: _statusColor(message.status),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.done;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
    }
  }

  Color _statusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
      case MessageStatus.delivered:
        return Colors.white70;
      case MessageStatus.read:
        return AppColors.lightPrimary;
    }
  }
}
