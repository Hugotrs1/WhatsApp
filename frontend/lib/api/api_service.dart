import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
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

  static const String _tokenKey = 'auth_token';

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://127.0.0.1:8080';
    }
    return 'http://127.0.0.1:8080';
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
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

  Future<Map<String, dynamic>> getMessages({
    required String from,
    required String to,
  }) {
    return _request(
      'GET',
      '/messages',
      queryParameters: {
        'from': from,
        'to': to,
      },
    );
  }

  Future<Map<String, dynamic>> sendMessage({
    required String from,
    required String to,
    required String content,
  }) {
    return _request(
      'POST',
      '/messages/send',
      body: {
        'from': from,
        'to': to,
        'content': content,
      },
    );
  }

  Future<Map<String, dynamic>> deleteMessage({required String id}) {
    return _request('DELETE', '/messages/$id');
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
      return _error(
        status: response.statusCode,
        code: 'http_error',
        message: 'HTTP ${response.statusCode}',
        details: parsed,
      );
    } catch (error) {
      return _error(
        status: 0,
        code: 'network_error',
        message: error.toString(),
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
  Future<Map<String, dynamic>> getInfo() async {
    final primary = await _request('GET', '/api/health');
    if (primary['status'] != 404) {
      return primary;
    }
    return _request('GET', '/');
  }
}
