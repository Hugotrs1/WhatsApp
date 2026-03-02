// ignore_for_file: file_names
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import '../api/apiService.dart';
import '../models/chat.dart';
import '../styles/styles.dart';
import '../utils/notificationFeedback.dart';
import '../utils/utils.dart';
import '../widget/avatar.dart';
import '../widget/messageView.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.chat});

  final Chat chat;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  static const String _genericErrorMessage = 'Une erreur est survenue. Veuillez réessayer.';

  late final ApiService _apiService;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isFetching = false;
  bool _isSending = false;
  bool _estConnecte = false;
  DateTime? _lastSeen;
  String? _loadError;
  int? _currentUserId;
  int _lastMessageId = 0;
  Timer? _pollingTimer;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadConnectionStatus();
    _loadMessages(reset: true);
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollUpdates());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _apiService.dispose();
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
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chat.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    _statusLabel(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesBody(),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: WhatsAppStyles.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isSending ? null : _sendMessage,
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

  Widget _buildMessagesBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshMessages,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            Center(
              child: Text(
                _loadError ?? 'Aucun message pour le moment.',
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
                    onPressed: () => _loadMessages(reset: true),
                    child: const Text('Reessayer'),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMessages,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          if (!message.isMine) {
            return MessageBubble(message: message);
          }
          return Dismissible(
            key: ValueKey('message-${message.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            confirmDismiss: (_) => _confirmDelete(message),
            onDismissed: (_) {
              if (!mounted) return;
              setState(() {
                _messages.removeWhere((m) => m.id == message.id);
              });
            },
            child: MessageBubble(message: message),
          );
        },
      ),
    );
  }

  Future<void> _refreshMessages() async {
    await _loadMessages();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (_isSending) return;
    if (text.isEmpty) {
      _showMessageError("Merci d'ecrire un message.");
      return;
    }
    _controller.clear();
    setState(() {
      _isSending = true;
    });

    try {
      final response = await _apiService.sendMessage(
        receiverId: widget.chat.id,
        content: text,
      );
      if (!mounted) return;

      if (response['ok'] == true) {
        await _loadMessages();
      } else {
        _controller.text = text;
        _showMessageError(_apiService.readErrorMessage(response));
      }
    } catch (error, stackTrace) {
      log(
        "Erreur lors de l'envoi du message",
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _controller.text = text;
      _showMessageError(_genericErrorMessage);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<bool> _confirmDelete(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer le message ?'),
            content: const Text('Cette action est definitive.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return false;
    try {
      final response = await _apiService.deleteMessage(id: message.id);
      if (!mounted) return false;
      if (response['ok'] == true) {
        return true;
      }
      _showMessageError(_apiService.readErrorMessage(response));
      return false;
    } catch (_) {
      if (mounted) {
        _showMessageError(_genericErrorMessage);
      }
      return false;
    }
  }

  Future<void> _loadMessages({bool reset = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      if (reset) {
        setState(() {
          _isLoading = true;
          _loadError = null;
          _lastMessageId = 0;
          _messages.clear();
          _hasLoadedOnce = false;
        });
      }

      _currentUserId ??= await _readCurrentUserId();
      final response = await _apiService.getMessages(
        withUserId: widget.chat.id,
        after: reset ? 0 : _lastMessageId,
      );
      if (!mounted) return;

      if (response['ok'] == true) {
        final data = response['data'];
        final parsed = _parseMessages(data, _currentUserId);
        final newLastId = _maxMessageId(data);
        final hasIncoming =
            !reset && _hasLoadedOnce && parsed.any((message) => !message.isMine);
        setState(() {
          _loadError = null;
          if (reset) {
            _messages
              ..clear()
              ..addAll(parsed);
          } else {
            _messages.addAll(parsed);
          }
          if (newLastId > _lastMessageId) {
            _lastMessageId = newLastId;
          }
          _isLoading = false;
        });
        if (hasIncoming) {
          NotificationFeedback.play();
        }
        _hasLoadedOnce = true;
        if (parsed.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      } else {
        setState(() {
          _isLoading = false;
          _loadError = _apiService.readErrorMessage(response);
        });
      }
    } catch (error, stackTrace) {
      log(
        'Erreur lors du chargement des messages',
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

  Future<void> _pollUpdates() async {
    await _loadMessages();
    await _loadConnectionStatus();
  }

  Future<void> _loadConnectionStatus() async {
    try {
      final response = await _apiService.getStatusForUser(userId: widget.chat.id);
      if (!mounted) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final appearOffline = data is Map && data['appear_offline'] == true;
        final lastSeenRaw = data is Map ? data['last_seen']?.toString() : null;
        final lastSeen = tryParseDateTime(lastSeenRaw);
        setState(() {
          _estConnecte = !appearOffline;
          _lastSeen = lastSeen;
        });
      }
    } catch (_) {
      // ignore errors for status
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 60,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<int?> _readCurrentUserId() async {
    final token = await _apiService.getToken();
    return decodeJwtUserId(token);
  }

  List<ChatMessage> _parseMessages(dynamic data, int? currentUserId) {
    final parsed = parseList<ChatMessage>(data, (map) {
      return ChatMessage.fromApi(
        map,
        chatTitle: widget.chat.title,
        currentUserId: currentUserId,
      );
    });
    parsed.sort((a, b) => a.time.compareTo(b.time));
    return parsed;
  }

  int _maxMessageId(dynamic data) {
    if (data is! List) return _lastMessageId;
    var maxId = _lastMessageId;
    for (final item in data) {
      if (item is! Map) continue;
      final id = parseInt(item['id']);
      if (id != null && id > maxId) {
        maxId = id;
      }
    }
    return maxId;
  }

  String _statusLabel() {
    if (_estConnecte) {
      return 'En ligne';
    }
    if (_lastSeen != null) {
      return formatLastSeen(_lastSeen!);
    }
    return 'Hors ligne';
  }

  void _showMessageError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
