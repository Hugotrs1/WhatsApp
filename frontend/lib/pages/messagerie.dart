import 'dart:async';
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
      'Une erreur est survenue. Veuillez réessayer.';
  static const Duration _searchDebounceDelay = Duration(milliseconds: 320);

  late final ApiService _apiService;
  final List<Chat> _chats = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  int _searchToken = 0;
  List<Map<String, dynamic>> _suggestions = [];
  String _query = '';
  bool _isLoading = true;
  bool _isFetching = false;
  bool _isSearching = false;
  String? _loadError;
  String? _searchError;
  bool _isHiding = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _searchController.addListener(_onQueryChanged);
    _loadConversations();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
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
            controller: _searchController,
            decoration: WhatsAppStyles.searchFieldDecoration(
              hintText: 'Rechercher ou démarrer une discussion',
            ),
            onChanged: (_) => _onQueryChanged(),
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

    final children = <Widget>[];
    final showSuggestions = _query.trim().isNotEmpty;

    if (showSuggestions) {
      children.add(_buildSuggestionsSection());
      children.add(const SizedBox(height: 8));
    }

    if (filteredChats.isEmpty) {
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
                child: const Text('Réessayer'),
              ),
            ),
          ),
      ]);
    } else {
      for (var i = 0; i < filteredChats.length; i++) {
        final chat = filteredChats[i];
        children.add(
          Dismissible(
            key: ValueKey(chat.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            confirmDismiss: (_) => _confirmHide(chat),
            child: ChatListTile(
              chat: chat,
              onTap: () => _openChat(chat),
            ),
          ),
        );
        if (i != filteredChats.length - 1) {
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

  Widget _buildSuggestionsSection() {
    final items = <Widget>[];
    if (_isSearching) {
      items.add(const LinearProgressIndicator());
    }
    if (_searchError != null) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _searchError!,
            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
    if (_suggestions.isEmpty && !_isSearching && _searchError == null) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Aucun utilisateur trouvé. Invite ton ami ou vérifie le numéro.',
            style: WhatsAppStyles.mutedBodyStyle(context),
          ),
        ),
      );
    }
    items.addAll(
      _suggestions.map(
        (s) => ListTile(
          leading: CircleAvatar(
            backgroundColor: WhatsAppStyles.primaryColor.withOpacity(0.1),
            child: Text(
              _suggestionInitials(s),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          title: Text(_suggestionName(s)),
          subtitle: Text(s['phone_masked']?.toString() ?? ''),
          trailing: const Icon(Icons.chat_outlined),
          onTap: () => _openSuggestion(s),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Suggestions',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
            ),
          ),
        ],
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

  void _onQueryChanged() {
    setState(() {
      _query = _searchController.text;
    });
    _searchDebounce?.cancel();
    if (_query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _searchError = null;
      });
      return;
    }
    _searchDebounce = Timer(_searchDebounceDelay, _performSearch);
  }

  Future<void> _performSearch() async {
    final digits = _query.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length < 2) {
      return;
    }
    final token = ++_searchToken;
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final response = await _apiService.searchUsersByPhonePrefix(
        phonePrefix: digits,
        limit: 10,
      );
      if (!mounted || token != _searchToken) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final list = <Map<String, dynamic>>[];
        if (data is List) {
          for (final item in data) {
            if (item is Map) {
              list.add(Map<String, dynamic>.from(item));
            }
          }
        }
        setState(() {
          _suggestions = list;
          _isSearching = false;
        });
      } else {
        setState(() {
          _isSearching = false;
          _searchError = _readErrorMessage(response);
        });
      }
    } catch (error, stackTrace) {
      log(
        'Erreur recherche utilisateur',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted || token != _searchToken) return;
      setState(() {
        _isSearching = false;
        _searchError = _genericErrorMessage;
      });
    }
  }

  Future<void> _openSuggestion(Map<String, dynamic> suggestion) async {
    final userId = suggestion['id']?.toString();
    if (userId == null || userId.isEmpty) return;
    final response = await _apiService.createDirectConversation(userId: userId);
    if (!mounted) return;
    if (response['ok'] != true) {
      _showSnackBar(_readErrorMessage(response));
      return;
    }
    final data = response['data'];
    if (data is! Map) {
      _showSnackBar(_genericErrorMessage);
      return;
    }
    final chat = _chatFromDirectConversation(data);
    _openChat(chat);
  }

  void _openChat(Chat chat) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(chat: chat),
      ),
    );
    await _refreshConversations();
  }

  Future<bool> _confirmHide(Chat chat) async {
    if (_isHiding) return false;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer la conversation ?'),
            content: const Text('Elle disparaîtra de ta liste mais les messages seront conservés.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return false;
    setState(() => _isHiding = true);
    try {
      final response = await _apiService.hideConversation(userId: chat.id);
      if (response['ok'] != true) {
        _showSnackBar(_readErrorMessage(response));
        return false;
      }
      setState(() {
        _chats.removeWhere((c) => c.id == chat.id);
      });
      return true;
    } catch (_) {
      _showSnackBar(_genericErrorMessage);
      return false;
    } finally {
      setState(() => _isHiding = false);
    }
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

  Chat _chatFromDirectConversation(Map data) {
    final id = data['user_id']?.toString() ?? '';
    final first = data['first_name']?.toString() ?? '';
    final last = data['last_name']?.toString() ?? '';
    final fullName = '$first $last'.trim().isEmpty ? 'Utilisateur' : '$first $last'.trim();
    final lastMessageData = data['last_message'];
    String lastMessage = 'Envoyer un premier message';
    DateTime lastActivity = DateTime.now();
    if (lastMessageData is Map) {
      final typeValue = lastMessageData['type']?.toString();
      final content = lastMessageData['content']?.toString() ?? '';
      lastActivity = _parseMessageTime(lastMessageData['created_at']);
      if (typeValue == 'image') {
        lastMessage = content.isEmpty ? 'Photo' : 'Photo - $content';
      } else {
        lastMessage = content.isEmpty ? 'Aucun message' : content;
      }
    }
    return Chat(
      id: id,
      title: fullName,
      lastMessage: lastMessage,
      lastActivity: lastActivity,
      messages: const [],
      avatarUrl: null,
    );
  }

  String _buildTitle(Map item) {
    final firstName = item['first_name']?.toString().trim() ?? '';
    final lastName = item['last_name']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? 'Utilisateur' : fullName;
  }

  String _suggestionName(Map item) {
    final first = item['first_name']?.toString() ?? '';
    final last = item['last_name']?.toString() ?? '';
    final full = '$first $last'.trim();
    return full.isEmpty ? 'Utilisateur' : full;
  }

  String _suggestionInitials(Map item) {
    final name = _suggestionName(item);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
