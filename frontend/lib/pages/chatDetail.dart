// ignore_for_file: file_names
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apiService.dart';
import '../models/chat.dart';
import '../styles/styles.dart';
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
  String? _loadError;
  int? _currentUserId;
  int _lastMessageId = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadConnectionStatus();
    _loadMessages(reset: true);
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) => _loadMessages());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
                    _estConnecte ? 'En ligne' : 'Hors ligne',
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
        _showMessageError(_readErrorMessage(response));
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
        _showMessageError(_readErrorMessage(response));
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
        if (parsed.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      } else {
        setState(() {
          _isLoading = false;
          _loadError = _readErrorMessage(response);
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

  Future<void> _loadConnectionStatus() async {
    try {
      final response = await _apiService.getStatusForUser(userId: widget.chat.id);
      if (!mounted) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final appearOffline = data is Map && data['appear_offline'] == true;
        setState(() {
          _estConnecte = !appearOffline;
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
    return _decodeUserId(token);
  }

  int? _decodeUserId(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        final sub = data['sub'];
        if (sub is int) return sub;
        if (sub is String) return int.tryParse(sub);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  List<ChatMessage> _parseMessages(dynamic data, int? currentUserId) {
    if (data is! List) return [];
    final parsed = <ChatMessage>[];
    for (final item in data) {
      if (item is! Map) continue;
      final content = item['content']?.toString() ?? '';
      final typeValue = item['type']?.toString().toLowerCase();
      final messageType = typeValue == 'image' ? MessageType.image : MessageType.text;
      final mediaUrl =
          messageType == MessageType.image ? _resolveMediaUrl(item['media_url']?.toString()) : null;
      if (messageType == MessageType.text && content.isEmpty) continue;
      if (messageType == MessageType.image && (mediaUrl == null || mediaUrl.isEmpty)) {
        continue;
      }
      final senderId = _asInt(item['sender_id']);
      final isMine = currentUserId != null && senderId == currentUserId;
      parsed.add(
        ChatMessage(
          id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          sender: isMine ? 'Moi' : widget.chat.title,
          content: content,
          time: _parseMessageTime(item['created_at']),
          isMine: isMine,
          status: MessageStatus.sent,
          type: messageType,
          mediaUrl: mediaUrl,
        ),
      );
    }
    parsed.sort((a, b) => a.time.compareTo(b.time));
    return parsed;
  }

  int _maxMessageId(dynamic data) {
    if (data is! List) return _lastMessageId;
    var maxId = _lastMessageId;
    for (final item in data) {
      if (item is! Map) continue;
      final id = _asInt(item['id']);
      if (id != null && id > maxId) {
        maxId = id;
      }
    }
    return maxId;
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  DateTime _parseMessageTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
      final parsed = DateTime.tryParse(normalized);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  String? _resolveMediaUrl(String? mediaUrl) {
    if (mediaUrl == null) return null;
    final trimmed = mediaUrl.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = _apiService.baseUrl.endsWith('/')
        ? _apiService.baseUrl.substring(0, _apiService.baseUrl.length - 1)
        : _apiService.baseUrl;
    final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$normalized';
  }

  String _readErrorMessage(Map<String, dynamic> response) {
    final error = response['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    if (error is String) return error;
    return _genericErrorMessage;
  }

  void _showMessageError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
