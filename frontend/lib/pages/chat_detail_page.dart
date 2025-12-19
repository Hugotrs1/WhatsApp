import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../styles/whatsapp_style.dart';
import '../widget/avatar.dart';
import '../widget/message_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [...widget.chat.messages]..sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppStyles.backgroundColor,
      appBar: AppBar(
        leadingWidth: 90,
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(
              initials: widget.chat.title.isNotEmpty ? widget.chat.title[0] : '?',
              imageUrl: widget.chat.avatarUrl,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    'en ligne',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.videocam),
          SizedBox(width: 12),
          Icon(Icons.call),
          SizedBox(width: 12),
          Icon(Icons.more_vert),
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showStatus = message.isMine && index == _messages.length - 1;
                return MessageBubble(
                  message: message,
                  showStatus: showStatus,
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: WhatsAppStyles.messageComposerDecoration,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: WhatsAppStyles.messageInputDecoration,
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: WhatsAppStyles.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'Moi',
      content: text,
      time: DateTime.now(),
      isMine: true,
      status: MessageStatus.sent,
    );
    setState(() {
      _messages.add(newMessage);
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 60,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }
}
