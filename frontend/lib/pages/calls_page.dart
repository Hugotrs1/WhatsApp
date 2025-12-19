import 'package:flutter/material.dart';

import '../utils/mock_data.dart';
import '../widget/call_list_tile.dart';

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final call = calls[index];
        return CallListTile(call: call);
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: calls.length,
    );
  }
}
