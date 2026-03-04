import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/chat.dart';
import '../models/userSummary.dart';
import '../styles/styles.dart';
import '../utils/notificationFeedback.dart';
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
      'Une erreur est survenue. Veuillez réessayer.';
  static const Duration _searchDebounceDelay = Duration(milliseconds: 320);

  late final ApiService _apiService;
  final List<Chat> _chats = [];
  final List<UserSummary> _friends = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  Timer? _pollingTimer;
  final Map<String, int> _lastMessageIdByChat = {};
  bool _hasLoadedOnce = false;
  String _query = '';
  bool _isLoading = true;
  bool _isFetching = false;
  bool _isFriendsLoading = false;
  String? _loadError;
  String? _friendsError;
  int? _currentUserId;
  List<UserSummary> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _searchController.addListener(_onQueryChanged);
    _loadConversations();
    _loadFriends();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollConversations());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _pollingTimer?.cancel();
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = _filterChats();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: WhatsAppStyles.searchFieldDecoration(
              hintText: 'Rechercher un ami',
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
          ChatListTile(
            chat: chat,
            onTap: () => _openChat(chat),
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
    if (_isFriendsLoading) {
      items.add(const LinearProgressIndicator());
    }
    if (_friendsError != null) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _friendsError!,
            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }
    if (_suggestions.isEmpty && !_isFriendsLoading && _friendsError == null) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Aucun ami trouve.',
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
              s.initials,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          title: Text(s.displayName),
          subtitle: Text(s.displayPhone),
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
              'Amis',
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
    await _loadFriends();
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

      _currentUserId ??= await _apiService.getCurrentUserId();
      final response = await _apiService.getConversations();
      if (!mounted) return;

      if (response['ok'] == true) {
        final data = response['data'];
        final shouldNotify = _shouldNotifyForNewMessages(data, notify: _hasLoadedOnce);
        final parsed = _parseConversations(data);
        setState(() {
          _chats
            ..clear()
            ..addAll(parsed);
          _isLoading = false;
          _loadError = null;
        });
        if (shouldNotify && (ModalRoute.of(context)?.isCurrent ?? true)) {
          NotificationFeedback.play();
        }
        _hasLoadedOnce = true;
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

  bool _shouldNotifyForNewMessages(dynamic data, {required bool notify}) {
    if (data is! List) return false;
    if (_currentUserId == null) return false;
    var shouldNotify = false;
    for (final item in data) {
      if (item is! Map) continue;
      final id = item['user_id']?.toString() ?? item['id']?.toString();
      if (id == null || id.isEmpty) continue;
      final messageId = item['message_id'] is int
          ? item['message_id'] as int
          : int.tryParse(item['message_id']?.toString() ?? '') ?? 0;
      final prev = _lastMessageIdByChat[id] ?? 0;
      _lastMessageIdByChat[id] = messageId;
      if (messageId <= prev) continue;
      final senderId = item['sender_id'] is int
          ? item['sender_id'] as int
          : int.tryParse(item['sender_id']?.toString() ?? '') ?? 0;
      if (notify && senderId != _currentUserId && senderId > 0) {
        shouldNotify = true;
      }
    }
    return shouldNotify;
  }

  Future<void> _pollConversations() async {
    if (!mounted) return;
    await _loadConversations();
  }

  void _onQueryChanged() {
    setState(() {
      _query = _searchController.text;
    });
    _searchDebounce?.cancel();
    if (_query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    _loadFriends();
    _searchDebounce = Timer(_searchDebounceDelay, _performSearch);
  }

  Future<void> _performSearch() async {
    final query = _query.trim();
    if (query.isEmpty) return;
    final suggestions = _filterFriends(query);
    if (!mounted) return;
    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<void> _openSuggestion(UserSummary suggestion) async {
    final userId = suggestion.id;
    if (userId.isEmpty) return;
    final existingChat = _findChatByUserId(userId);
    if (existingChat != null) {
      _openChat(existingChat);
      return;
    }
    final response = await _apiService.createDirectConversation(userId: userId);
    if (!mounted) return;
    if (response['ok'] != true) {
      _showSnackBar(_apiService.readErrorMessage(response));
      return;
    }
    final data = response['data'];
    if (data is! Map) {
      _showSnackBar(_genericErrorMessage);
      return;
    }
    final chat =
        Chat.fromDirectConversation(Map<String, dynamic>.from(data), fallbackId: userId);
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

  List<Chat> _parseConversations(dynamic data) {
    return parseList<Chat>(data, (map) {
      final chat = Chat.fromConversation(map);
      return chat.id.isEmpty ? null : chat;
    });
  }

  List<UserSummary> _filterFriends(String query) {
    final q = query.toLowerCase();
    final digits = normalizeDigits(query);
    return _friends.where((friend) {
      final name = friend.displayName.toLowerCase();
      final matchName = name.contains(q);
      final matchPhone = digits.isNotEmpty && friend.phoneDigits.contains(digits);
      return matchName || matchPhone;
    }).toList();
  }

  Chat? _findChatByUserId(String userId) {
    for (final chat in _chats) {
      if (chat.id == userId) return chat;
    }
    return null;
  }

  List<Chat> _filterChats() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return List<Chat>.from(_chats);
    return _chats.where((chat) {
      return chat.title.toLowerCase().contains(q) ||
          chat.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _loadFriends() async {
    if (_isFriendsLoading) return;
    setState(() {
      _isFriendsLoading = true;
      _friendsError = null;
    });
    try {
      final response = await _apiService.listFriends();
      if (!mounted) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final list = parseList<UserSummary>(data, (map) => UserSummary.fromMap(map));
        setState(() {
          _friends
            ..clear()
            ..addAll(list);
          _isFriendsLoading = false;
          if (_query.trim().isNotEmpty) {
            _suggestions = _filterFriends(_query.trim());
          }
        });
      } else {
        setState(() {
          _isFriendsLoading = false;
          _friendsError = _apiService.readErrorMessage(response);
        });
      }
    } catch (error, stackTrace) {
      log('Erreur chargement amis', error: error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isFriendsLoading = false;
        _friendsError = _genericErrorMessage;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
