import 'dart:developer';

import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/chat.dart';
import '../styles/styles.dart';
import '../widget/chatListTile.dart';
import 'chatDetail.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  static const String _genericErrorMessage =
      'Une erreur est survenue. Veuillez reessayer.';

  late final ApiService _apiService;
  final List<Chat> _chats = [];
  String _query = '';
  bool _isLoading = true;
  bool _isFetching = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadConversations();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Chat> filteredChats = _chats.where((chat) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return chat.title.toLowerCase().contains(q) || chat.lastMessage.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: WhatsAppStyles.searchFieldDecoration(
              hintText: 'Rechercher ou démarrer une discussion',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: _buildBody(filteredChats),
        ),
      ],
    );
  }

  Widget _buildBody(List<Chat> filteredChats) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredChats.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshConversations,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            Center(
              child: Text(
                _loadError ?? 'Aucune conversation pour le moment.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (_loadError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: TextButton(
                    onPressed: _loadConversations,
                    child: const Text('Reessayer'),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshConversations,
      child: ListView.separated(
        itemBuilder: (context, index) {
          final chat = filteredChats[index];
          return ChatListTile(
            chat: chat,
            onTap: () => _openChat(chat),
          );
        },
        separatorBuilder: (_, __) => Divider(height: 1, color: WhatsAppStyles.dividerColor),
        itemCount: filteredChats.length,
      ),
    );
  }

  Future<void> _refreshConversations() async {
    await _loadConversations(reset: true);
  }

  Future<void> _loadConversations({bool reset = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      if (reset) {
        setState(() {
          _isLoading = true;
          _loadError = null;
        });
      }

      final response = await _apiService.getConversations();
      if (!mounted) return;

      if (response['ok'] == true) {
        final data = response['data'];
        final parsed = _parseConversations(data);
        setState(() {
          _chats
            ..clear()
            ..addAll(parsed);
          _isLoading = false;
          _loadError = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _loadError = _readErrorMessage(response);
        });
      }
    } catch (error, stackTrace) {
      log(
        'Erreur lors du chargement des conversations',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = _genericErrorMessage;
      });
    } finally {
      _isFetching = false;
    }
  }

  void _openChat(Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(chat: chat),
      ),
    );
  }

  List<Chat> _parseConversations(dynamic data) {
    if (data is! List) return [];
    final chats = <Chat>[];
    for (final item in data) {
      if (item is! Map) continue;
      final id = item['user_id']?.toString() ?? item['id']?.toString();
      if (id == null || id.isEmpty) continue;
      final title = _buildTitle(item);
      final typeValue = item['type']?.toString().toLowerCase();
      final content = item['content']?.toString() ?? '';
      final trimmedContent = content.trim();
      final lastMessage = typeValue == 'image'
          ? (trimmedContent.isEmpty ? 'Photo' : 'Photo - $trimmedContent')
          : (trimmedContent.isEmpty ? 'Aucun message' : trimmedContent);
      chats.add(
        Chat(
          id: id,
          title: title,
          lastMessage: lastMessage,
          lastActivity: _parseMessageTime(item['created_at']),
          messages: const [],
          unreadCount: 0,
          isMuted: false,
          isPinned: false,
          isGroup: false,
        ),
      );
    }
    return chats;
  }

  String _buildTitle(Map item) {
    final firstName = item['first_name']?.toString().trim() ?? '';
    final lastName = item['last_name']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'Utilisateur' : fullName;
  }

  DateTime _parseMessageTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
      final parsed = DateTime.tryParse(normalized);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  String _readErrorMessage(Map<String, dynamic> response) {
    final error = response['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    if (error is String) return error;
    return _genericErrorMessage;
  }
}
