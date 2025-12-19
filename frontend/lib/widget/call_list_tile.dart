import 'package:flutter/material.dart';

import '../models/call_entry.dart';
import '../utils/app_colors.dart';
import 'avatar.dart';

class CallListTile extends StatelessWidget {
  const CallListTile({
    super.key,
    required this.call,
  });

  final CallEntry call;

  @override
  Widget build(BuildContext context) {
    final directionIcon = call.direction == CallDirection.outgoing ? Icons.north_east : Icons.south_west;
    final directionColor = call.missed ? Colors.red : AppColors.primary;

    return ListTile(
      leading: Avatar(
        initials: call.contact.isNotEmpty ? call.contact[0] : '?',
        imageUrl: call.avatarUrl,
        radius: 24,
      ),
      title: Text(
        call.contact,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Row(
        children: [
          Icon(directionIcon, size: 16, color: directionColor),
          const SizedBox(width: 4),
          Text(
            call.missed ? 'Appel manqué' : 'Il y a ${_agoText(call.time)}',
            style: TextStyle(color: call.missed ? Colors.red : Colors.grey.shade700),
          ),
        ],
      ),
      trailing: Icon(
        call.isVideo ? Icons.videocam : Icons.call,
        color: AppColors.primary,
      ),
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
