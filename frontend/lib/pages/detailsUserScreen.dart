import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/chat.dart';
import '../models/demandeAmi.dart';
import '../models/profileUser.dart';
import '../styles/styles.dart';
import 'conversationScreen.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key, required this.userId});

  final String userId;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  static const String _genericErrorMessage = 'Une erreur est survenue. Veuillez réessayer.';

  late final ApiService _apiService;
  bool _isLoading = true;
  bool _isActionRunning = false;
  String? _error;
  UserProfile? _profile;
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
    final relation = _profile?.relation;
    final isFriend = relation?.isFriend == true;
    final incoming = relation?.incomingRequest;
    final outgoing = relation?.outgoingRequest;
    final isMe = _currentUserId != null && _profile?.id == _currentUserId?.toString();

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
    required FriendRequest? incoming,
    required FriendRequest? outgoing,
    required bool isMe,
  }) {
    final profile = _profile!;
    final fullName = profile.displayName;
    final phoneMasked = profile.displayPhone;

    return ListView(
      padding: WhatsAppStyles.pagePadding,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: WhatsAppStyles.primaryColor.withOpacity(0.12),
              child: Text(
                profile.initials,
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
    required FriendRequest? incoming,
    required FriendRequest? outgoing,
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
    } else if (incoming?.isPending == true) {
      label = 'Souhaite vous ajouter';
      color = Colors.orange.shade700;
    } else if (outgoing?.isPending == true) {
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
    required FriendRequest? incoming,
    required FriendRequest? outgoing,
  }) {
    final hasIncoming = incoming?.isPending == true;
    final hasOutgoing = outgoing?.isPending == true;

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
                  onPressed: _isActionRunning ? null : () => _respondToRequest(incoming?.id, true),
                  child: const Text('Accepter'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isActionRunning ? null : () => _respondToRequest(incoming?.id, false),
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
                  onPressed: _isActionRunning ? null : () => _cancelRequest(outgoing?.id),
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
            _profile = UserProfile.fromMap(Map<String, dynamic>.from(data));
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
    final relation = _profile?.relation;
    final isFriend = relation?.isFriend == true;
    final incoming = relation?.incomingRequest;
    final outgoing = relation?.outgoingRequest;
    if (isFriend) {
      _showSnackBar('Vous êtes déjà amis.');
      return;
    }
    if (outgoing?.isPending == true) {
      _showSnackBar('Demande déjà envoyée.');
      return;
    }
    if (incoming?.isPending == true) {
      _showSnackBar('Cette personne vous a déjà envoyé une demande.');
      return;
    }

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

  Future<void> _respondToRequest(String? requestId, bool accept) async {
    if (requestId == null) return;
    setState(() => _isActionRunning = true);
    try {
      final id = requestId;
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

  Future<void> _cancelRequest(String? requestId) async {
    if (requestId == null) return;
    setState(() => _isActionRunning = true);
    try {
      final response = await _apiService.cancelFriendRequest(requestId: requestId);
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
      final chat =
          Chat.fromDirectConversation(Map<String, dynamic>.from(data), fallbackId: widget.userId);
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatDetailPage(chat: chat)),
      );
    } finally {
      if (mounted) {
        setState(() => _isActionRunning = false);
      }
    }
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
