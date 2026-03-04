import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp/data/storage/secureStorage.dart';

import 'api/apiService.dart';
import 'data/storage/credentialsStorage.dart';
import 'data/storage/tokenStorage.dart';
import 'domain/auth/authService.dart';
import 'presentation/bootstrap/startup.dart';
import 'styles/appTheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('Optional .env not loaded: $error');
  }
  await _requestNotificationPermission();
  final secureStorage = SecureStorage();
  final tokenStorage = TokenStorage(secureStorage);
  final credentialsStorage = CredentialsStorage(secureStorage);
  final apiService = ApiService(
    secureStorage: secureStorage,
    tokenStorage: tokenStorage,
    credentialsStorage: credentialsStorage,
  );
  final authService = AuthService(
    apiService: apiService,
    tokenStorage: tokenStorage,
    credentialsStorage: credentialsStorage,
  );
  runApp(WhatsappApp(authService: authService));
}

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}

class WhatsappApp extends StatelessWidget {
  const WhatsappApp({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: AppBootstrap(authService: authService),
    );
  }
}
