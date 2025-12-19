import 'package:flutter/material.dart';

import '../models/status_update.dart';
import '../utils/mock_data.dart';
import '../widget/avatar.dart';
import '../widget/section_header.dart';
import '../widget/status_list_tile.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    StatusUpdate? myStatus;
    for (final entry in statusUpdates) {
      if (entry.user == 'Mon statut') {
        myStatus = entry;
        break;
      }
    }
    final List<StatusUpdate> recent = statusUpdates.where((s) => s.user != 'Mon statut' && !s.isMuted).toList();
    final List<StatusUpdate> muted = statusUpdates.where((s) => s.isMuted).toList();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: ListTile(
            leading: Stack(
              children: [
                Avatar(
                  initials: myStatus?.initials ?? 'MO',
                  imageUrl: myStatus?.avatarUrl,
                  radius: 26,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            title: const Text('Mon statut', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Appuyer pour ajouter une mise à jour'),
          ),
        ),
        const SectionHeader('Récentes mises à jour'),
        ...recent.map((s) => StatusListTile(status: s)),
        if (muted.isNotEmpty) ...[
          const SectionHeader('Mises à jour muettes'),
          ...muted.map((s) => StatusListTile(status: s)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
