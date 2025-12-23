import 'package:flutter/material.dart';

import '../../domain/auth/authModele.dart';
import '../../domain/auth/authService.dart';
import '../../pages/accueil.dart';
import '../auth/authController.dart';
import '../auth/authPage.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<AuthBootstrapResult> _bootstrap;
  AuthController? _controller;

  @override
  void initState() {
    super.initState();
    _bootstrap = widget.authService.bootstrap();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthBootstrapResult>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashPage();
        }
        final data = snapshot.data ??
            const AuthBootstrapResult(
              status: AuthStatus.unauthenticated,
              rememberedCredentials: null,
            );
        _controller ??= AuthController(
          authService: widget.authService,
          bootstrap: data,
        );
        return AuthScope(
          controller: _controller!,
          child: const AppRouter(),
        );
      },
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AuthScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.status == AuthStatus.authenticated) {
          return const HomePage();
        }
        return const AuthPage();
      },
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 140,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, color: colorScheme.primary, size: 48),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
