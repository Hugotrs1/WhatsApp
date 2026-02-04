import 'dart:convert';

import 'package:intl/intl.dart';

String buildDisplayName({
  String? firstName,
  String? lastName,
  String fallback = 'Utilisateur',
}) {
  final first = firstName?.trim() ?? '';
  final last = lastName?.trim() ?? '';
  final full = '$first $last'.trim();
  return full.isEmpty ? fallback : full;
}

String initialsFromName(String name, {String fallback = '?'}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return fallback;
  return trimmed[0].toUpperCase();
}

String normalizeDigits(String value) {
  return value.replaceAll(RegExp(r'\D'), '');
}

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

DateTime parseDateTime(dynamic value, {DateTime? fallback}) {
  if (value is String && value.trim().isNotEmpty) {
    final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) return parsed;
  }
  return fallback ?? DateTime.now();
}

DateTime? tryParseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final normalized = value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
  return DateTime.tryParse(normalized);
}

String formatLastSeen(DateTime value, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final isSameDay =
      current.year == value.year && current.month == value.month && current.day == value.day;
  if (isSameDay) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return 'Vu a $hh:$mm';
  }
  final dd = value.day.toString().padLeft(2, '0');
  final mm = value.month.toString().padLeft(2, '0');
  return 'Vu le $dd/$mm';
}

String? resolveMediaUrl(String? mediaUrl, String baseUrl) {
  if (mediaUrl == null) return null;
  final trimmed = mediaUrl.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  final normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$normalized';
}

int? decodeJwtUserId(String? token) {
  if (token == null || token.isEmpty) return null;
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final data = jsonDecode(payload);
    if (data is Map<String, dynamic>) {
      final sub = data['sub'];
      if (sub is int) return sub;
      if (sub is String) return int.tryParse(sub);
    }
  } catch (_) {
    return null;
  }
  return null;
}

List<T> parseList<T>(
  dynamic data,
  T? Function(Map<String, dynamic>) builder,
) {
  if (data is! List) return [];
  final items = <T>[];
  for (final item in data) {
    if (item is! Map) continue;
    final mapped = builder(Map<String, dynamic>.from(item));
    if (mapped != null) {
      items.add(mapped);
    }
  }
  return items;
}

String formatTemps(DateTime time) {
  final now = DateTime.now();
  final isSameDay = now.year == time.year && now.month == time.month && now.day == time.day;
  if (isSameDay) {
    return DateFormat.Hm().format(time);
  }
  final isSameYear = now.year == time.year;
  final format = isSameYear ? DateFormat('dd/MM') : DateFormat('dd/MM/yy');
  return format.format(time);
}
