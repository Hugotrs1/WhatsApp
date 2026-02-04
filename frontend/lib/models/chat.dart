import '../utils/utils.dart';

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

  static MessageType parseType(String? value) {
    final typeValue = value?.toLowerCase() ?? '';
    return typeValue == 'image' ? MessageType.image : MessageType.text;
  }

  static ChatMessage? fromApi(
    Map<String, dynamic> map, {
    required String chatTitle,
    required String baseUrl,
    int? currentUserId,
  }) {
    final type = parseType(map['type']?.toString());
    final content = map['content']?.toString() ?? '';
    final mediaUrl = type == MessageType.image
        ? resolveMediaUrl(map['media_url']?.toString(), baseUrl)
        : null;
    if (type == MessageType.text && content.trim().isEmpty) return null;
    if (type == MessageType.image && (mediaUrl == null || mediaUrl.isEmpty)) {
      return null;
    }
    final senderId = parseInt(map['sender_id']);
    final isMine = currentUserId != null && senderId == currentUserId;
    return ChatMessage(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sender: isMine ? 'Moi' : chatTitle,
      content: content,
      time: parseDateTime(map['created_at']),
      isMine: isMine,
      status: MessageStatus.sent,
      type: type,
      mediaUrl: mediaUrl,
    );
  }
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

  static String buildLastMessage({required String? type, required String content}) {
    final trimmed = content.trim();
    if (type == 'image') {
      return trimmed.isEmpty ? 'Photo' : 'Photo - $trimmed';
    }
    return trimmed.isEmpty ? 'Aucun message' : trimmed;
  }

  factory Chat.fromConversation(Map<String, dynamic> map) {
    final id = map['user_id']?.toString() ?? map['id']?.toString() ?? '';
    final title = buildDisplayName(
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
    );
    final typeValue = map['type']?.toString().toLowerCase();
    final content = map['content']?.toString() ?? '';
    final unreadCount = parseInt(map['unread_count']) ?? 0;
    return Chat(
      id: id,
      title: title,
      lastMessage: buildLastMessage(type: typeValue, content: content),
      lastActivity: parseDateTime(map['created_at']),
      messages: const [],
      unreadCount: unreadCount,
      isMuted: false,
      isPinned: false,
      isGroup: false,
    );
  }

  factory Chat.fromDirectConversation(
    Map<String, dynamic> data, {
    String? fallbackId,
  }) {
    final id = data['user_id']?.toString() ?? fallbackId ?? '';
    final title = buildDisplayName(
      firstName: data['first_name']?.toString(),
      lastName: data['last_name']?.toString(),
    );
    final lastMessageData = data['last_message'];
    String lastMessage = 'Envoyer un premier message';
    DateTime lastActivity = DateTime.now();
    if (lastMessageData is Map<String, dynamic>) {
      final typeValue = lastMessageData['type']?.toString();
      final content = lastMessageData['content']?.toString() ?? '';
      lastActivity = parseDateTime(lastMessageData['created_at']);
      lastMessage = buildLastMessage(type: typeValue, content: content);
    }
    return Chat(
      id: id,
      title: title,
      lastMessage: lastMessage,
      lastActivity: lastActivity,
      messages: const [],
      avatarUrl: null,
    );
  }
}
