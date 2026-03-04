import '../utils/utils.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.time,
    this.isMine = false,
  });

  final String id;
  final String sender;
  final String content;
  final DateTime time;
  final bool isMine;

  static ChatMessage? fromApi(Map<String, dynamic> map, {required String chatTitle,int? currentUserId}) {
    final content = map['content']?.toString() ?? '';
    if (content.trim().isEmpty) return null;
    final senderId = parseInt(map['sender_id']);
    final isMine = currentUserId != null && senderId == currentUserId;
    return ChatMessage(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sender: isMine ? 'Moi' : chatTitle,
      content: content,
      time: parseDateTime(map['created_at']),
      isMine: isMine,
    );
  }
}

class Chat {
  const Chat({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastActivity;
  final int unreadCount;

  static String buildLastMessage(String content) {
    final trimmed = content.trim();
    return trimmed.isEmpty ? 'Aucun message' : trimmed;
  }

  factory Chat.fromConversation(Map<String, dynamic> map) {
    final id = map['user_id']?.toString() ?? map['id']?.toString() ?? '';
    final title = buildDisplayName(
      firstName: map['first_name']?.toString(),
      lastName: map['last_name']?.toString(),
    );
    final content = map['content']?.toString() ?? '';
    final unreadCount = parseInt(map['unread_count']) ?? 0;
    return Chat(
      id: id,
      title: title,
      lastMessage: buildLastMessage(content),
      lastActivity: parseDateTime(map['created_at']),
      unreadCount: unreadCount,
    );
  }

  factory Chat.fromDirectConversation(Map<String, dynamic> data, {String? fallbackId}) {
    final id = data['user_id']?.toString() ?? fallbackId ?? '';
    final title = buildDisplayName(
      firstName: data['first_name']?.toString(),
      lastName: data['last_name']?.toString(),
    );
    final lastMessageData = data['last_message'];
    String lastMessage = 'Envoyer un premier message';
    DateTime lastActivity = DateTime.now();
    if (lastMessageData is Map<String, dynamic>) {
      final content = lastMessageData['content']?.toString() ?? '';
      lastActivity = parseDateTime(lastMessageData['created_at']);
      lastMessage = buildLastMessage(content);
    }
    return Chat(
      id: id,
      title: title,
      lastMessage: lastMessage,
      lastActivity: lastActivity,
      unreadCount: 0,
    );
  }
}
