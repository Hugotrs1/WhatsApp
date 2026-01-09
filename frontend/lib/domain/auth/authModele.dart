// ignore_for_file: file_names
enum AuthStatus {
  checking,
  authenticated,
  unauthenticated,
}

class RememberedCredentials {
  const RememberedCredentials({
    required this.phone,
    required this.password,
    required this.rememberMe,
  });

  final String phone;
  final String password;
  final bool rememberMe;
}

class AuthBootstrapResult {
  const AuthBootstrapResult({
    required this.status,
    required this.rememberedCredentials,
  });

  final AuthStatus status;
  final RememberedCredentials? rememberedCredentials;
}

class AuthResult {
  const AuthResult._(this.isSuccess, this.message);

  const AuthResult.success([String? message]) : this._(true, message);

  const AuthResult.failure(String message) : this._(false, message);

  final bool isSuccess;
  final String? message;
}
