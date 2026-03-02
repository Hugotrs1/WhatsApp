import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/chat.dart';
import '../styles/styles.dart';
import '../utils/utils.dart';
import '../widget/conversationTiles.dart';
import 'conversationScreen.dart';

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
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isFetching = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadConversations();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollConversations());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(_chats);
  }

  Widget _buildBody(List<Chat> chats) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final children = <Widget>[];

    if (chats.isEmpty) {
      children.addAll([
        const SizedBox(height: 120),
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
      ]);
    } else {
      for (var i = 0; i < chats.length; i++) {
        final chat = chats[i];
        children.add(
          ChatListTile(
            chat: chat,
            onTap: () => _openChat(chat),
          ),
        );
        if (i != chats.length - 1) {
          children.add(Divider(height: 1, color: WhatsAppStyles.dividerColor));
        }
      }
    }

    return RefreshIndicator(
      onRefresh: _refreshConversations,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: children,
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
          _loadError = _apiService.readErrorMessage(response);
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

  Future<void> _pollConversations() async {
    if (!mounted) return;
    await _loadConversations();
  }

  void _openChat(Chat chat) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(chat: chat),
      ),
    );
    await _refreshConversations();
  }

  List<Chat> _parseConversations(dynamic data) {
    return parseList<Chat>(data, (map) {
      final chat = Chat.fromConversation(map);
      return chat.id.isEmpty ? null : chat;
    });
  }
}
