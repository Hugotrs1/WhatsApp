import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/mock_data.dart';
import '../widget/avatar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final me = statusUpdates.first;

    return ListView(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Avatar(
                initials: me.initials,
                imageUrl: me.avatarUrl,
                radius: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Moi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('+33 6 12 34 56 78', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ],
          ),
        ),
        const Divider(height: 1),
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
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 1),
      ],
    );
  }
}
