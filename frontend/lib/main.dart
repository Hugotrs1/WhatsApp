import 'package:flutter/material.dart';

import 'pages/auth_page.dart';
import 'styles/app_theme.dart';

void main() {
  runApp(const WhatsappApp());
}

class WhatsappApp extends StatelessWidget {
  const WhatsappApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: const AuthPage(),
    );
  }
}
