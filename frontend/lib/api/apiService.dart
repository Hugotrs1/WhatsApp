// ignore_for_file: file_names
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../data/storage/stockageConfidentiel.dart';
import '../data/storage/stockageSecurise.dart';
import '../data/storage/stockageToken.dart';

const int _jsonIsolateThreshold = 20000;

class ApiService {
  factory ApiService({
    String? baseUrl,
    http.Client? client,
    Duration? timeout,
    SecureStorage? secureStorage,
    TokenStorage? tokenStorage,
    CredentialsStorage? credentialsStorage,
  }) {
    final resolvedStorage = secureStorage ?? SecureStorage();
    return ApiService._internal(
      baseUrl: baseUrl ?? _defaultBaseUrl(),
      client: client ?? http.Client(),
      timeout: timeout ?? const Duration(seconds: 15),
      tokenStorage: tokenStorage ?? TokenStorage(resolvedStorage),
      credentialsStorage: credentialsStorage ?? CredentialsStorage(resolvedStorage),
    );
  }

  ApiService._internal({
    required this.baseUrl,
    required http.Client client,
    required Duration timeout,
    required TokenStorage tokenStorage,
    required CredentialsStorage credentialsStorage,
  })  : _client = client,
        _timeout = timeout,
        _tokenStorage = tokenStorage,
        _credentialsStorage = credentialsStorage;

  static const String _genericErrorMessage =
      'Une erreur est survenue. Veuillez réessayer.';

  final String baseUrl;
  final http.Client _client;
  final Duration _timeout;
  final TokenStorage _tokenStorage;
  final CredentialsStorage _credentialsStorage;

  static String _defaultBaseUrl() {
    final envBaseUrl = dotenv.env['API_BASE_URL']?.trim();
    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    return 'http://localhost:8080';
  }

  static String normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0033')) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('33')) {
      final rest = digits.substring(2);
      if (rest.length == 9) {
        return '0$rest';
      }
      if (rest.length == 10 && rest.startsWith('0')) {
        return rest;
      }
    }
    return digits;
  }

  static bool isValidPhone(String value) {
    final normalized = normalizePhone(value);
    return RegExp(r'^\d{10}$').hasMatch(normalized);
  }

  Future<void> saveToken(String token) async {
    await _tokenStorage.saveToken(token);
  }

  Future<String?> getToken() {
    return _tokenStorage.readToken();
  }

  Future<int?> getCurrentUserId() {
    return _tokenStorage.readUserId();
  }

  Future<void> clearToken() async {
    await _tokenStorage.clearToken();
  }

  Future<void> saveRememberedCredentials({
    required String phone,
    required String password,
  }) async {
    await _credentialsStorage.save(
      phone: normalizePhone(phone),
      password: password,
    );
  }

  Future<Map<String, String>?> getRememberedCredentials() async {
    final remembered = await _credentialsStorage.read();
    if (remembered == null) {
      return null;
    }
    return {
      'phone': remembered.phone,
      'password': remembered.password,
    };
  }

  Future<void> clearRememberedCredentials() async {
    await _credentialsStorage.clear();
  }

  Future<void> clearAuthState({bool clearRemembered = false}) async {
    await clearToken();
    if (clearRemembered) {
      await clearRememberedCredentials();
    }
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) {
    final normalizedPhone = normalizePhone(phone);
    return _request(
      'POST',
      '/api/login',
      body: {
        'phone': normalizedPhone,
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
    final normalizedPhone = normalizePhone(phone);
    return _request(
      'POST',
      '/api/register',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': normalizedPhone,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>> searchUsersByPhonePrefix({
    required String phonePrefix,
    int limit = 10,
  }) {
    return _request(
      'GET',
      '/api/users/search',
      queryParameters: {
        'phonePrefix': phonePrefix,
        'limit': limit.toString(),
      },
    );
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) {
    return _request('GET', '/api/users/$userId');
  }

  Future<Map<String, dynamic>> createFriendRequest({required String recipientId}) {
    return _request(
      'POST',
      '/api/friends/requests',
      body: {'recipientId': recipientId},
    );
  }

  Future<Map<String, dynamic>> acceptFriendRequest({required String requestId}) {
    return _request('POST', '/api/friends/requests/$requestId/accept');
  }

  Future<Map<String, dynamic>> declineFriendRequest({required String requestId}) {
    return _request('POST', '/api/friends/requests/$requestId/decline');
  }

  Future<Map<String, dynamic>> cancelFriendRequest({required String requestId}) {
    return _request('POST', '/api/friends/requests/$requestId/cancel');
  }

  Future<Map<String, dynamic>> listIncomingFriendRequests({String status = 'PENDING'}) {
    return _request(
      'GET',
      '/api/friends/requests/incoming',
      queryParameters: {'status': status},
    );
  }

  Future<Map<String, dynamic>> listFriends() {
    return _request('GET', '/api/friends');
  }

  Future<Map<String, dynamic>> getConversations() {
    return _request('GET', '/api/conversations');
  }

  Future<Map<String, dynamic>> createDirectConversation({required String userId}) {
    return _request(
      'POST',
      '/api/conversations/direct',
      body: {'userId': userId},
    );
  }

  Future<Map<String, dynamic>> updateStatus({required bool appearOffline}) {
    return _request(
      'POST',
      '/api/status',
      body: {'appear_offline': appearOffline},
    );
  }

  Future<Map<String, dynamic>> getStatusForUser({required String userId}) {
    return _request('GET', '/api/status/$userId');
  }

  Future<Map<String, dynamic>> getMyStatus() async {
    final me = await _tokenStorage.readUserId();
    if (me == null) {
      return _error(status: 401, code: 'unauthorized', message: 'Non authentifié.');
    }
    return getStatusForUser(userId: me.toString());
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

  Future<Map<String, dynamic>> deleteMessage({required String id}) {
    return _request('DELETE', '/api/messages/$id');
  }

  Future<Map<String, dynamic>> listAllUsers({int limit = 100}) {
    return _request(
      'GET',
      '/api/users',
      queryParameters: {
        'limit': limit.toString(),
      },
    );
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
    final token = await _tokenStorage.readToken();
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

      final parsed = await _tryParseJson(response.body);
      if (parsed is Map && parsed.containsKey('ok')) {
        if (response.statusCode == 401) {
          await clearAuthState();
        }
        final normalized = Map<String, dynamic>.from(parsed);
        normalized['status'] = response.statusCode;
        return normalized;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _ok(status: response.statusCode, data: parsed);
      }
      if (response.statusCode == 401) {
        await clearAuthState();
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

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final baseUri = Uri.parse(baseUrl);
    final resolved = baseUri.resolve(path);
    if (queryParameters == null || queryParameters.isEmpty) {
      return resolved;
    }
    return resolved.replace(queryParameters: queryParameters);
  }

  Future<dynamic> _tryParseJson(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      if (trimmed.length < _jsonIsolateThreshold) {
        return jsonDecode(trimmed);
      }
      return await compute(_decodeJson, trimmed);
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
        return 'Requête invalide.';
      case 401:
        return 'Authentification requise.';
      case 403:
        return 'Accès refusé.';
      case 404:
        return 'Ressource introuvable.';
      case 408:
        return 'Délai dépassé. Réessaie.';
      case 413:
        return 'Fichier trop volumineux. Réduis la taille du fichier.';
      case 429:
        return 'Trop de requêtes. Réessaie plus tard.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Erreur serveur. Réessaie plus tard.';
      default:
        return _genericErrorMessage;
    }
  }

  String readErrorMessage(Map<String, dynamic> response) {
    final error = response['error'];
    if (error is Map) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final details = error['details'];
      if (details is String && details.trim().isNotEmpty) {
        return details.trim();
      }
      if (details is Map && details['message'] is String) {
        final detailsMessage = details['message'] as String;
        if (detailsMessage.trim().isNotEmpty) {
          return detailsMessage.trim();
        }
      }
      return _genericErrorMessage;
    }
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }
    return _genericErrorMessage;
  }

  String? _extractMessage(dynamic details) {
    if (details is Map) {
      final message = details['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final fieldMessage = _extractFieldError(details);
      if (fieldMessage != null) {
        return fieldMessage;
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

  String? _extractFieldError(Map details) {
    final fieldErrors = details['details'];
    if (fieldErrors is! Map || fieldErrors.isEmpty) {
      return null;
    }
    final entry = fieldErrors.entries.first;
    final field = entry.key.toString();
    final code = entry.value.toString();
    return _formatFieldError(field, code);
  }

  String? _formatFieldError(String field, String code) {
    final label = _fieldLabel(field);
    if (label == null) {
      return null;
    }
    switch (code) {
      case 'required':
        return '$label requis.';
      case 'format':
        return '$label invalide.';
      default:
        return null;
    }
  }

  String? _fieldLabel(String field) {
    switch (field) {
      case 'phone':
        return 'Téléphone';
      case 'password':
        return 'Mot de passe';
      case 'first_name':
        return 'Prénom';
      case 'last_name':
        return 'Nom';
      default:
        return null;
    }
  }

  String? _extractMessageFromRaw(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.contains('413 Request Entity Too Large') ||
        normalized.contains('Request Entity Too Large')) {
      return 'Fichier trop volumineux. Réduis la taille du fichier.';
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

dynamic _decodeJson(String body) {
  return jsonDecode(body);
}
