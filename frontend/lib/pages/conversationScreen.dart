// ignore_for_file: file_names
import 'dart:async';
import 'dart:developer';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apiService.dart';
import '../models/chat.dart';
import '../styles/styles.dart';
import '../utils/notificationSound.dart';
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
  static const String _genericErrorMessage =
      'Une erreur est survenue. Veuillez reessayer.';

  late final ApiService _apiService;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final List<ChatMessage> _messages = [];
  bool _showEmojiPicker = false;
  bool _isLoading = true;
  bool _isFetching = false;
  bool _isSending = false;
  bool _estConnecte = false;
  bool _isTypingRemote = false;
  bool _isTypingSelf = false;
  DateTime? _lastSeen;
  String? _loadError;
  int? _currentUserId;
  int _lastMessageId = 0;
  Timer? _pollingTimer;
  Timer? _typingDebounce;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _controller.addListener(_onTypingChanged);
    _loadConnectionStatus();
    _loadMessages(reset: true);
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 400), (_) => _pollUpdates());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _typingDebounce?.cancel();
    _setTyping(false);
    _controller.removeListener(_onTypingChanged);
    _controller.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
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
                  IconButton(
                    onPressed: _toggleEmojiPicker,
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
                              focusNode: _inputFocusNode,
                              decoration: WhatsAppStyles.messageInputDecoration,
                              minLines: 1,
                              maxLines: 4,
                              onTap: _hideEmojiPicker,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed: _pickAttachment,
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined),
                            onPressed: _openCamera,
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
          if (_showEmojiPicker)
            SizedBox(
              height: 280,
              child: EmojiPicker(
                textEditingController: _controller,
                config: Config(),
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
          final showStatus = message.isMine && index == _messages.length - 1;
          return MessageBubble(
            message: message,
            showStatus: showStatus,
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
    _setTyping(false);
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

  Future<void> _sendImageMessage(XFile image) async {
    if (_isSending) return;
    final caption = _controller.text.trim();
    _setTyping(false);
    _controller.clear();
    setState(() {
      _isSending = true;
    });

    try {
      final response = await _apiService.sendImageMessage(
        receiverId: widget.chat.id,
        imagePath: image.path,
        caption: caption.isEmpty ? null : caption,
      );
      if (!mounted) return;

      if (response['ok'] == true) {
        await _loadMessages();
      } else {
        if (caption.isNotEmpty) {
          _controller.text = caption;
        }
        _showMessageError(_apiService.readErrorMessage(response));
      }
    } catch (error, stackTrace) {
      log(
        "Erreur lors de l'envoi de la photo",
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      if (caption.isNotEmpty) {
        _controller.text = caption;
      }
      _showMessageError(_genericErrorMessage);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
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
        final hasIncoming = !reset && _hasLoadedOnce && _hasIncomingMessages(parsed);
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
          NotificationSound.playNotification();
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
    await _loadTypingStatus();
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

  Future<void> _loadTypingStatus() async {
    try {
      final response = await _apiService.getTypingStatus(userId: widget.chat.id);
      if (!mounted) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final isTyping = data is Map && data['is_typing'] == true;
        if (isTyping != _isTypingRemote) {
          setState(() {
            _isTypingRemote = isTyping;
          });
        }
      }
    } catch (_) {
      // ignore errors for typing
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

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
    if (_showEmojiPicker) {
      _inputFocusNode.unfocus();
    } else {
      _inputFocusNode.requestFocus();
    }
  }

  void _hideEmojiPicker() {
    if (!_showEmojiPicker) return;
    setState(() {
      _showEmojiPicker = false;
    });
  }

  void _onTypingChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText) {
      _setTyping(true);
      _typingDebounce?.cancel();
      _typingDebounce = Timer(const Duration(seconds: 2), () {
        _setTyping(false);
      });
    } else {
      _typingDebounce?.cancel();
      _setTyping(false);
    }
  }

  Future<void> _setTyping(bool isTyping) async {
    if (_isTypingSelf == isTyping) return;
    _isTypingSelf = isTyping;
    try {
      await _apiService.setTyping(userId: widget.chat.id, isTyping: isTyping);
    } catch (_) {
      // ignore typing errors
    }
  }

  Future<void> _pickAttachment() async {
    _hideEmojiPicker();
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (!mounted || image == null) return;
      await _sendImageMessage(image);
    } catch (error, stackTrace) {
      log(
        'Erreur galerie',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      _showMessageError(_genericErrorMessage);
    }
  }

  Future<void> _openCamera() async {
    _hideEmojiPicker();
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (!mounted || image == null) return;
      await _sendImageMessage(image);
    } catch (error, stackTrace) {
      log(
        'Erreur caméra',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
        ),
      );
    }
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
        baseUrl: _apiService.baseUrl,
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

  bool _hasIncomingMessages(List<ChatMessage> messages) {
    for (final message in messages) {
      if (!message.isMine) return true;
    }
    return false;
  }

  String _statusLabel() {
    if (_isTypingRemote) {
      return 'écrit...';
    }
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
