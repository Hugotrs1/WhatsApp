import 'dart:convert';

import 'package:whatsapp/data/storage/stockageSecurise.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const String _tokenKey = 'auth_token';

  final SecureStorage _storage;
  String? _cachedToken;

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.writeString(_tokenKey, token);
  }

  Future<String?> readToken() async {
    final token = _cachedToken ?? await _storage.readString(_tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }
    if (_isTokenExpired(token)) {
      await clearToken();
      return null;
    }
    _cachedToken = token;
    return token;
  }

  Future<void> clearToken() async {
    _cachedToken = null;
    await _storage.delete(_tokenKey);
  }

  Future<int?> readUserId() async {
    final token = await readToken();
    return decodeUserId(token);
  }

  int? decodeUserId(String? token) {
    if (token == null || token.isEmpty) return null;
    final data = _decodeJwtPayload(token);
    if (data == null) return null;
    final sub = data['sub'];
    if (sub is int) return sub;
    if (sub is String) return int.tryParse(sub);
    return null;
  }

  bool _isTokenExpired(String token) {
    final data = _decodeJwtPayload(token);
    if (data == null) return false;
    final exp = data['exp'];
    final expSeconds = exp is int ? exp : exp is String ? int.tryParse(exp) : null;
    if (expSeconds == null) return false;
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return nowSeconds >= expSeconds;
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(payload);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }
}
