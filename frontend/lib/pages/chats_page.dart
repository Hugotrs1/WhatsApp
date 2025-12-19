import 'package:flutter/material.dart';

import '../models/chat.dart';
import '../utils/mock_data.dart';
import '../widget/chat_list_tile.dart';
import 'chat_detail_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<Chat> filteredChats = chats.where((chat) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return chat.title.toLowerCase().contains(q) || chat.lastMessage.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher ou démarrer une discussion',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return ChatListTile(
                chat: chat,
                onTap: () => _openChat(chat),
              );
            },
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
            itemCount: filteredChats.length,
          ),
        ),
      ],
    );
  }

  void _openChat(Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(chat: chat),
      ),
    );
  }
}
