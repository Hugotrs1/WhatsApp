import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../styles/styles.dart';
import '../widget/avatar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final ApiService _apiService;
  bool _estConnecte = true;
  bool _isLoadingStatus = true;
  String? _statusError;
  String? _displayName;
  String? _phoneMasked;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadConnectionStatus();
    _loadProfile();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        _displayName?.trim().isNotEmpty == true ? _displayName!.trim() : 'Utilisateur';
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
    final phone = _phoneMasked ?? '';

    return ListView(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Avatar(
                initials: initials,
                imageUrl: null,
                radius: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ],
          ),
        ),
        const Divider(height: 1),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          value: _estConnecte,
          onChanged: _isLoadingStatus ? null : _toggleConnectionStatus,
          activeColor: WhatsAppStyles.primaryColor,
          title: const Text('En ligne', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            _statusError ?? (_estConnecte ? 'Statut visible' : 'Statut masqué'),
            style: TextStyle(color: _statusError == null ? Colors.grey : Colors.red.shade700),
          ),
        ),
        Divider(height: 1, color: WhatsAppStyles.dividerColor),
        _SettingsTile(icon: Icons.vpn_key, title: 'Compte', subtitle: 'Confidentialité, sécurité, changer de numéro'),
        _SettingsTile(icon: Icons.lock_outline, title: 'Confidentialité', subtitle: 'Verrouillage par empreinte, contacts bloqués'),
        _SettingsTile(icon: Icons.chat_bubble_outline, title: 'Discussions', subtitle: 'Thèmes, fonds d’écran, historique'),
        _SettingsTile(icon: Icons.notifications_none, title: 'Notifications', subtitle: 'Sons de message, groupes, appels'),
        _SettingsTile(icon: Icons.data_saver_off, title: 'Stockage et données', subtitle: 'Utilisation réseau, téléchargement auto'),
        _SettingsTile(icon: Icons.help_outline, title: 'Aide', subtitle: 'Centre d’aide, contact'),
        
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Meta • 2025',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _loadConnectionStatus() async {
    try {
      final response = await _apiService.getMyStatus();
      if (!mounted) return;
      if (response['ok'] == true) {
        final data = response['data'];
        final appearOffline = data is Map && data['appear_offline'] == true;
        setState(() {
          _estConnecte = !appearOffline;
          _isLoadingStatus = false;
          _statusError = null;
        });
      } else {
        setState(() {
          _isLoadingStatus = false;
          _statusError = _apiService.readErrorMessage(response);
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingStatus = false;
        _statusError = 'Impossible de charger le statut';
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final userId = await _apiService.getCurrentUserId();
      if (userId == null) {
        if (!mounted) return;
        setState(() {
          _displayName = 'Utilisateur';
          _phoneMasked = '';
        });
        return;
      }
      final response = await _apiService.getUserProfile(userId.toString());
      if (!mounted) return;
      if (response['ok'] == true) {
        final data = response['data'];
        if (data is Map) {
          final firstName = data['first_name']?.toString() ?? '';
          final lastName = data['last_name']?.toString() ?? '';
          final fullName = '$firstName $lastName'.trim();
          setState(() {
            _displayName = fullName.isEmpty ? 'Utilisateur' : fullName;
            _phoneMasked = data['phone']?.toString() ?? data['phone_masked']?.toString() ?? '';
          });
          return;
        }
      }
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _toggleConnectionStatus(bool value) async {
    setState(() {
      _estConnecte = value;
      _statusError = null;
      _isLoadingStatus = true;
    });
    try {
      final response = await _apiService.updateStatus(appearOffline: !value);
      if (!mounted) return;
      if (response['ok'] != true) {
        setState(() {
          _statusError = _apiService.readErrorMessage(response);
        });
      }
    } finally {
      if (mounted) {
        _isLoadingStatus = false;
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: WhatsAppStyles.primaryColor.withValues(alpha: 0.08),
            child: Icon(icon, color: WhatsAppStyles.primaryColor),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        Divider(height: 1, color: WhatsAppStyles.dividerColor),
      ],
    );
  }
}
