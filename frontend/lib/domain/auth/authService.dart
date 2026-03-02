// ignore_for_file: file_names
import '../../api/apiService.dart';
import '../../data/storage/stockageConfidentiel.dart';
import '../../data/storage/stockageToken.dart';
import 'authModele.dart';

class AuthService {
  AuthService({
    required ApiService apiService,
    required TokenStorage tokenStorage,
    required CredentialsStorage credentialsStorage,
  })  : _apiService = apiService,
        _tokenStorage = tokenStorage,
        _credentialsStorage = credentialsStorage;

  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  final CredentialsStorage _credentialsStorage;

  Future<AuthBootstrapResult> bootstrap() async {
    final remembered = await _credentialsStorage.read();
    final token = await _tokenStorage.readToken();
    final status = token == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    return AuthBootstrapResult(
      status: status,
      rememberedCredentials: remembered,
    );
  }

  Future<AuthResult> login({
    required String phone,
    required String password,
    required bool rememberMe,
  }) async {
    final normalizedPhone = ApiService.normalizePhone(phone.trim());
    final response = await _apiService.login(
      phone: normalizedPhone,
      password: password,
    );
    final token = _extractToken(response);
    if (response['ok'] == true && token != null) {
      await _tokenStorage.saveToken(token);
      if (rememberMe) {
        await _credentialsStorage.save(
          phone: normalizedPhone,
          password: password,
        );
      } else {
        await _credentialsStorage.clear();
      }
      return const AuthResult.success();
    }
    if (response['ok'] == true && token == null) {
      return const AuthResult.failure('Connexion impossible. Token manquant.');
    }
    if (response['status'] == 401 || response['status'] == 422) {
      await _tokenStorage.clearToken();
      if (!rememberMe) {
        await _credentialsStorage.clear();
      }
    }
    return AuthResult.failure(_apiService.readErrorMessage(response));
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = ApiService.normalizePhone(phone.trim());
    final response = await _apiService.register(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: normalizedPhone,
      password: password.trim(),
    );
    if (response['ok'] == true) {
      return const AuthResult.success('Compte créé. Connecte-toi.');
    }
    return AuthResult.failure(_apiService.readErrorMessage(response));
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  Future<void> clearRememberedCredentials() {
    return _credentialsStorage.clear();
  }

  String? _extractToken(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map && data['token'] is String) {
      return data['token'] as String;
    }
    // Support wrapped payloads: {ok:true, data:{token:...}}
    if (data is Map && data['data'] is Map && data['data']['token'] is String) {
      return data['data']['token'] as String;
    }
    return null;
  }
}
