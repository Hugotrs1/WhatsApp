import 'package:flutter/material.dart';

import '../models/status_update.dart';
import 'avatar.dart';

class StatusListTile extends StatelessWidget {
  const StatusListTile({
    super.key,
    required this.status,
  });

  final StatusUpdate status;

  @override
  Widget build(BuildContext context) {
    if (status.stories.isEmpty) return const SizedBox.shrink();

    final latest = status.stories.reduce((a, b) => a.time.isAfter(b.time) ? a : b);
    return ListTile(
      leading: Avatar(
        initials: status.initials,
        imageUrl: status.avatarUrl,
        highlight: !status.isMuted,
        muted: status.isMuted,
        radius: 26,
      ),
      title: Text(
        status.user,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        'Il y a ${_agoText(latest.time)} • ${status.stories.length} statut(s)',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      trailing: const Icon(Icons.more_vert),
    );
  }

  String _agoText(DateTime time) {
    final minutes = DateTime.now().difference(time).inMinutes;
    if (minutes < 60) return '$minutes min';
    final hours = (minutes / 60).floor();
    if (hours < 24) return '${hours}h';
    final days = (hours / 24).floor();
    return '${days}j';
  }
}
