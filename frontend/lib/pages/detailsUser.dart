import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/chat.dart';
import '../styles/styles.dart';
import 'chatDetail.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, required this.userId});

  final String userId;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  static const String _genericErrorMessage = 'Une erreur est survenue. Veuillez reessayer.';

  late final ApiService _apiService;
  bool _isLoading = true;
  bool _isActionRunning = false;
  String? _error;
  Map<String, dynamic>? _profile;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadCurrentUserId().then((_) => _loadProfile());
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relation = _profile?['relation'] as Map<String, dynamic>?;
    final isFriend = relation?['is_friend'] == true;
    final incoming = relation?['incoming_request'] as Map<String, dynamic>?;
    final outgoing = relation?['outgoing_request'] as Map<String, dynamic>?;
    final isMe = _currentUserId != null && _profile?['id'] == _currentUserId;

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? _ErrorView(message: _error!, onRetry: _loadProfile)
            : _profile == null
                ? const SizedBox.shrink()
                : _buildBody(isFriend: isFriend, incoming: incoming, outgoing: outgoing, isMe: isMe);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: content,
    );
  }

  Widget _buildBody({
    required bool isFriend,
    required Map<String, dynamic>? incoming,
    required Map<String, dynamic>? outgoing,
    required bool isMe,
  }) {
    final firstName = _profile?['first_name']?.toString() ?? '';
    final lastName = _profile?['last_name']?.toString() ?? '';
    final phoneMasked = _profile?['phone_masked']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();

    return ListView(
      padding: WhatsAppStyles.pagePadding,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: WhatsAppStyles.primaryColor.withOpacity(0.12),
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isEmpty ? 'Utilisateur' : fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneMasked,
                    style: WhatsAppStyles.mutedBodyStyle(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildStatusCard(isFriend: isFriend, incoming: incoming, outgoing: outgoing, isMe: isMe),
        const SizedBox(height: 16),
        if (!isMe) _buildActions(isFriend: isFriend, incoming: incoming, outgoing: outgoing),
      ],
    );
  }

  Widget _buildStatusCard({
    required bool isFriend,
    required Map<String, dynamic>? incoming,
    required Map<String, dynamic>? outgoing,
    required bool isMe,
  }) {
    String label;
    Color color;
    if (isMe) {
      label = 'C\'est vous';
      color = Colors.grey.shade600;
    } else if (isFriend) {
      label = 'Vous êtes amis';
      color = Colors.green.shade700;
    } else if (incoming != null && incoming['status'] == 'PENDING') {
      label = 'Souhaite vous ajouter';
      color = Colors.orange.shade700;
    } else if (outgoing != null && outgoing['status'] == 'PENDING') {
      label = 'Demande envoyée';
      color = Colors.blue.shade700;
    } else {
      label = 'Pas encore amis';
      color = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: WhatsAppStyles.cardBorderRadius,
        border: Border.all(color: WhatsAppStyles.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions({
    required bool isFriend,
    required Map<String, dynamic>? incoming,
    required Map<String, dynamic>? outgoing,
  }) {
    final hasIncoming = incoming != null && incoming['status'] == 'PENDING';
    final hasOutgoing = outgoing != null && outgoing['status'] == 'PENDING';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isFriend)
          ElevatedButton.icon(
            onPressed: _isActionRunning ? null : _openChat,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Envoyer un message'),
          )
        else if (hasIncoming)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isActionRunning ? null : () => _respondToRequest(incoming['id'], true),
                  child: const Text('Accepter'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isActionRunning ? null : () => _respondToRequest(incoming['id'], false),
                  child: const Text('Décliner'),
                ),
              ),
            ],
          )
        else if (hasOutgoing)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isActionRunning ? null : () => _cancelRequest(outgoing['id']),
                  child: const Text('Annuler la demande'),
                ),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: _isActionRunning ? null : _sendFriendRequest,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Ajouter en ami'),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isActionRunning ? null : _openChat,
          icon: const Icon(Icons.chat_outlined),
          label: const Text('Démarrer une discussion'),
        ),
      ],
    );
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _apiService.getUserProfile(widget.userId);
      if (response['ok'] == true) {
        final data = response['data'];
        if (data is Map) {
          setState(() {
            _profile = Map<String, dynamic>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = _genericErrorMessage;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = _apiService.readErrorMessage(response);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _genericErrorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      _currentUserId = await _apiService.getCurrentUserId();
    } catch (_) {
      _currentUserId = null;
    }
  }

  Future<void> _sendFriendRequest() async {
    setState(() => _isActionRunning = true);
    try {
      final response = await _apiService.createFriendRequest(recipientId: widget.userId);
      if (!mounted) return;
      if (response['ok'] == true) {
        await _loadProfile();
        _showSnackBar('Demande envoyée.');
      } else {
        _showSnackBar(_apiService.readErrorMessage(response));
      }
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
  }

  Future<void> _respondToRequest(dynamic requestId, bool accept) async {
    if (requestId == null) return;
    setState(() => _isActionRunning = true);
    try {
      final id = requestId.toString();
      final response = accept
          ? await _apiService.acceptFriendRequest(requestId: id)
          : await _apiService.declineFriendRequest(requestId: id);
      if (!mounted) return;
      if (response['ok'] == true) {
        await _loadProfile();
        _showSnackBar(accept ? 'Demande acceptée.' : 'Demande déclinée.');
      } else {
        _showSnackBar(_apiService.readErrorMessage(response));
      }
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
  }

  Future<void> _cancelRequest(dynamic requestId) async {
    if (requestId == null) return;
    setState(() => _isActionRunning = true);
    try {
      final response = await _apiService.cancelFriendRequest(requestId: requestId.toString());
      if (!mounted) return;
      if (response['ok'] == true) {
        await _loadProfile();
        _showSnackBar('Demande annulée.');
      } else {
        _showSnackBar(_apiService.readErrorMessage(response));
      }
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
  }

  Future<void> _openChat() async {
    setState(() => _isActionRunning = true);
    try {
      final response = await _apiService.createDirectConversation(userId: widget.userId);
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
      final chat = _chatFromDirectConversation(data);
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatDetailPage(chat: chat)),
      );
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
  }

  Chat _chatFromDirectConversation(Map data) {
    final id = data['user_id']?.toString() ?? widget.userId;
    final firstName = data['first_name']?.toString() ?? '';
    final lastName = data['last_name']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim().isEmpty ? 'Utilisateur' : '$firstName $lastName'.trim();
    final last = data['last_message'];
    DateTime lastActivity = DateTime.now();
    String lastMessage = 'Envoyer un premier message';
    if (last is Map) {
      final typeValue = last['type']?.toString();
      final content = last['content']?.toString() ?? '';
      lastActivity = _parseTime(last['created_at']);
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

  DateTime _parseTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
      final parsed = DateTime.tryParse(normalized);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
