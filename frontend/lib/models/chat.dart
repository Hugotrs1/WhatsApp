enum MessageStatus { sent, delivered, read }
enum MessageType { text, image }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.time,
    this.isMine = false,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.mediaUrl,
    this.isVoice = false,
    this.isForwarded = false,
  });

  final String id;
  final String sender;
  final String content;
  final DateTime time;
  final bool isMine;
  final MessageStatus status;
  final MessageType type;
  final String? mediaUrl;
  final bool isVoice;
  final bool isForwarded;
}

class Chat {
  const Chat({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastActivity,
    required this.messages,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.isGroup = false,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastActivity;
  final List<ChatMessage> messages;
  final String? avatarUrl;
  final int unreadCount;
  final bool isMuted;
  final bool isPinned;
  final bool isGroup;
}
