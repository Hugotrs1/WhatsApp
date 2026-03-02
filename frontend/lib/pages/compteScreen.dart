import 'package:flutter/material.dart';

import '../api/apiService.dart';
import '../models/profileUser.dart';
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
    final displayName = _displayName?.trim().isNotEmpty == true ? _displayName!.trim() : 'Utilisateur';
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
            ],
          ),
        ),
        const Divider(height: 1),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          value: _estConnecte,
          onChanged: _isLoadingStatus ? null : _toggleConnectionStatus,
          activeThumbColor: WhatsAppStyles.primaryColor,
          title: const Text('En ligne', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            _statusError ?? (_estConnecte ? 'Statut visible' : 'Statut masqué'),
            style: TextStyle(color: _statusError == null ? Colors.grey : Colors.red.shade700),
          ),
        ),
        Divider(height: 1, color: WhatsAppStyles.dividerColor),
       
        const SizedBox(height: 24),
        Center(
          child: Text(
            'CESI • 2026',
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
          final profile = UserProfile.fromMap(Map<String, dynamic>.from(data));
          setState(() {
            _displayName = profile.displayName;
            _phoneMasked = profile.displayPhone;
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
