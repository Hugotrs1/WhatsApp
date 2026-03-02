import 'package:flutter/material.dart';
import 'package:whatsapp/utils/utils.dart';

import 'package:whatsapp/models/chat.dart';
import 'package:whatsapp/utils/appColors.dart';

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
    final hasImage = message.type == MessageType.image && (message.mediaUrl?.isNotEmpty ?? false);
    final content = message.content.trim();
    final heroTag = 'message-image-${message.id}';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: hasImage
            ? const EdgeInsets.all(6)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            if (hasImage) _buildImage(context, message.mediaUrl!, heroTag),
            if (hasImage && content.isNotEmpty) const SizedBox(height: 8),
            if (content.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  style: TextStyle(color: textColor, height: 1.3),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTemps(message.time),
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

  Widget _buildImage(BuildContext context, String url, String heroTag) {
    return GestureDetector(
      onTap: () => _openImagePreview(context, url, heroTag),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes == null
                        ? null
                        : progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: 220,
                height: 220,
                child: Center(
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey.shade500),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openImagePreview(BuildContext context, String url, String heroTag) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Center(
                  child: Hero(
                    tag: heroTag,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes == null
                                  ? null
                                  : progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image, size: 64, color: Colors.grey.shade400);
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
