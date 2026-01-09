import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:whatsapp/data/storage/stockageSecurise.dart';

import 'api/apiService.dart';
import 'data/storage/stockageConfidentiel.dart';
import 'data/storage/stockageToken.dart';
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

class WhatsappApp extends StatelessWidget {
  const WhatsappApp({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: AppBootstrap(authService: authService),
    );
  }
}
