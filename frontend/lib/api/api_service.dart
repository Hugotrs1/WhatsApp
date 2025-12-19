import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';
  static const String _rememberPhoneKey = 'remember_phone';
  static const String _rememberPasswordKey = 'remember_password';
  static const String _connectionStatusKey = 'est_connecte';
  static const String _genericErrorMessage =
      'Une erreur est survenue. Veuillez réessayer.';

  ApiService({
    String? baseUrl,
    http.Client? client,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl(),
        _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15);

  final String baseUrl;
  final http.Client _client;
  final Duration _timeout;

  static String _defaultBaseUrl() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://127.0.0.1:8080';
    }
    return 'http://127.0.0.1:8080';
  }

  Future<void> saveToken(String token) async {
    await spSave<String>(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return spGet<String>(_tokenKey);
  }

  Future<void> clearToken() async {
    await spDelete(_tokenKey);
  }

  Future<void> saveRememberedCredentials({
    required String phone,
    required String password,
  }) async {
    await spSave<String>(_rememberPhoneKey, phone);
    await spSave<String>(_rememberPasswordKey, password);
  }

  Future<Map<String, String>?> getRememberedCredentials() async {
    final phone = await spGet<String>(_rememberPhoneKey);
    final password = await spGet<String>(_rememberPasswordKey);
    if (phone == null || phone.isEmpty || password == null || password.isEmpty) {
      return null;
    }
    return {'phone': phone, 'password': password};
  }

  Future<void> clearRememberedCredentials() async {
    await spDelete(_rememberPhoneKey);
    await spDelete(_rememberPasswordKey);
  }

  Future<void> saveConnectionStatus({required bool estConnecte}) async {
    await spSave<bool>(_connectionStatusKey, estConnecte);
  }

  Future<bool> getConnectionStatus() async {
    return (await spGet<bool>(_connectionStatusKey)) ?? false;
  }

  Future<void> clearConnectionStatus() async {
    await spDelete(_connectionStatusKey);
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) {
    return _request(
      'POST',
      '/api/login',
      body: {
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
  }) {
    return _request(
      'POST',
      '/api/register',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> getUsers() {
    return _request('GET', '/users');
  }

  Future<Map<String, dynamic>> getConversations() {
    return _request('GET', '/api/conversations');
  }

  Future<Map<String, dynamic>> getMessages({
    required String withUserId,
    int after = 0,
  }) {
    return _request(
      'GET',
      '/api/messages',
      queryParameters: {
        'with': withUserId,
        'after': after.toString(),
      },
    );
  }

  Future<Map<String, dynamic>> sendMessage({
    required String receiverId,
    required String content,
  }) {
    return _request(
      'POST',
      '/api/messages',
      body: {
        'receiver_id': receiverId,
        'content': content,
      },
    );
  }

  Future<Map<String, dynamic>> sendImageMessage({
    required String receiverId,
    required String imagePath,
    String? caption,
  }) {
    final fields = <String, String>{
      'receiver_id': receiverId,
    };
    final trimmedCaption = caption?.trim();
    if (trimmedCaption != null && trimmedCaption.isNotEmpty) {
      fields['content'] = trimmedCaption;
    }
    return _multipartRequest(
      '/api/messages',
      fields: fields,
      fileField: 'image',
      filePath: imagePath,
    );
  }

  Future<Map<String, dynamic>> deleteMessage({required String id}) {
    return _request('DELETE', '/messages/$id');
  }

  Future<Map<String, dynamic>> getInfo() async {
    final primary = await _request('GET', '/api/health');
    if (primary['status'] != 404) {
      return primary;
    }
    return _request('GET', '/');
  }

  Future<void> spSave<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
      return;
    }
    if (value is bool) {
      await prefs.setBool(key, value);
      return;
    }
    if (value is int) {
      await prefs.setInt(key, value);
      return;
    }
    if (value is double) {
      await prefs.setDouble(key, value);
      return;
    }
    if (value is List<String>) {
      await prefs.setStringList(key, value);
      return;
    }
    throw ArgumentError('Unsupported SharedPreferences type: ${value.runtimeType}');
  }

  Future<T?> spGet<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (T == String) {
      return prefs.getString(key) as T?;
    }
    if (T == bool) {
      return prefs.getBool(key) as T?;
    }
    if (T == int) {
      return prefs.getInt(key) as T?;
    }
    if (T == double) {
      return prefs.getDouble(key) as T?;
    }
    if (T == List<String>) {
      return prefs.getStringList(key) as T?;
    }
    throw ArgumentError('Unsupported SharedPreferences type: $T');
  }

  Future<void> spDelete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  void dispose() {
    _client.close();
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final encodedBody = body == null ? null : jsonEncode(body);
      late http.Response response;

      switch (method) {
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(_timeout);
          break;
        case 'GET':
        default:
          response = await _client.get(uri, headers: headers).timeout(_timeout);
          break;
      }

      final parsed = _tryParseJson(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _ok(status: response.statusCode, data: parsed);
      }
      developer.log(
        'HTTP error ${response.statusCode} for $uri',
        name: 'ApiService',
        error: response.body,
      );
      return _error(
        status: response.statusCode,
        code: 'http_error',
        message: _buildErrorMessage(response.statusCode, parsed),
        details: parsed,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Network error for $uri',
        name: 'ApiService',
        error: error,
        stackTrace: stackTrace,
      );
      return _error(
        status: 0,
        code: 'network_error',
        message: _genericErrorMessage,
      );
    }
  }

  Future<Map<String, dynamic>> _multipartRequest(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String filePath,
  }) async {
    final uri = _buildUri(path, null);
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    try {
      final streamed = await request.send().timeout(_timeout);
      final body = await streamed.stream.bytesToString();
      final parsed = _tryParseJson(body);
      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        return _ok(status: streamed.statusCode, data: parsed);
      }
      developer.log(
        'HTTP error ${streamed.statusCode} for $uri',
        name: 'ApiService',
        error: body,
      );
      return _error(
        status: streamed.statusCode,
        code: 'http_error',
        message: _buildErrorMessage(streamed.statusCode, parsed),
        details: parsed,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Network error for $uri',
        name: 'ApiService',
        error: error,
        stackTrace: stackTrace,
      );
      return _error(
        status: 0,
        code: 'network_error',
        message: _genericErrorMessage,
      );
    }
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final baseUri = Uri.parse(baseUrl);
    final resolved = baseUri.resolve(path);
    if (queryParameters == null || queryParameters.isEmpty) {
      return resolved;
    }
    return resolved.replace(queryParameters: queryParameters);
  }

  dynamic _tryParseJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      return jsonDecode(trimmed);
    } catch (_) {
      return {'raw': body};
    }
  }

  String _buildErrorMessage(int status, dynamic details) {
    final extracted = _extractMessage(details);
    if (extracted != null) {
      return extracted;
    }
    switch (status) {
      case 400:
        return 'Requete invalide.';
      case 401:
        return 'Authentification requise.';
      case 403:
        return 'Acces refuse.';
      case 404:
        return 'Ressource introuvable.';
      case 408:
        return 'Delai depasse. Reessaye.';
      case 413:
        return 'Fichier trop volumineux. Reduis la taille du fichier.';
      case 429:
        return 'Trop de requetes. Reessaye plus tard.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Erreur serveur. Reessaye plus tard.';
      default:
        return _genericErrorMessage;
    }
  }

  String? _extractMessage(dynamic details) {
    if (details is Map) {
      final message = details['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final error = details['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
      final raw = details['raw'];
      if (raw is String) {
        return _extractMessageFromRaw(raw);
      }
      return null;
    }
    if (details is String) {
      final rawMessage = _extractMessageFromRaw(details);
      if (rawMessage != null) {
        return rawMessage;
      }
      final trimmed = details.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  String? _extractMessageFromRaw(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.contains('413 Request Entity Too Large') ||
        normalized.contains('Request Entity Too Large')) {
      return 'Fichier trop volumineux. Reduis la taille du fichier.';
    }
    if (RegExp(r'<[^>]+>').hasMatch(normalized)) {
      return null;
    }
    return normalized;
  }

  Map<String, dynamic> _ok({required int status, dynamic data}) {
    return {
      'ok': true,
      'status': status,
      'data': data ?? {},
      'error': null,
    };
  }

  Map<String, dynamic> _error({
    required int status,
    required String code,
    required String message,
    dynamic details,
  }) {
    return {
      'ok': false,
      'status': status,
      'data': {},
      'error': {
        'code': code,
        'message': message,
        'details': details,
      },
    };
  }
}
