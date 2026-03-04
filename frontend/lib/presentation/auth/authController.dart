import 'package:flutter/material.dart';

import '../../domain/auth/authModel.dart';
import '../../domain/auth/authService.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required AuthBootstrapResult bootstrap,
  })  : _authService = authService,
        _status = bootstrap.status,
        rememberedCredentials = bootstrap.rememberedCredentials;

  final AuthService _authService;
  final RememberedCredentials? rememberedCredentials;

  AuthStatus get status => _status;
  AuthStatus _status;

  Future<AuthResult> login({
    required String phone,
    required String password,
    required bool rememberMe,
  }) async {
    final result = await _authService.login(
      phone: phone,
      password: password,
      rememberMe: rememberMe,
    );
    if (result.isSuccess) {
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
    return result;
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) {
    return _authService.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
    );
  }

  Future<void> logout() async {
    await _authService.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> clearRememberedCredentials() {
    return _authService.clearRememberedCredentials();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    if (scope == null) {
      throw FlutterError('AuthScope not found in context.');
    }
    return scope.notifier!;
  }
}
