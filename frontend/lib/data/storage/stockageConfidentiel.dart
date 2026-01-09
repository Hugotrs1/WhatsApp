// ignore_for_file: file_names
import 'package:whatsapp/data/storage/stockageSecurise.dart';

import '../../domain/auth/authModele.dart';

class CredentialsStorage {
  CredentialsStorage(this._storage);

  static const String _rememberEnabledKey = 'remember_enabled';
  static const String _rememberPhoneKey = 'remember_phone';
  static const String _rememberPasswordKey = 'remember_password';

  final SecureStorage _storage;

  Future<void> save({
    required String phone,
    required String password,
  }) async {
    await _storage.writeString(_rememberPhoneKey, phone);
    await _storage.writeString(_rememberPasswordKey, password);
    await _storage.writeBool(_rememberEnabledKey, true);
  }

  Future<RememberedCredentials?> read() async {
    final rememberEnabled = await _storage.readBool(_rememberEnabledKey);
    final phone = await _storage.readString(_rememberPhoneKey);
    final password = await _storage.readString(_rememberPasswordKey);
    final enabled = rememberEnabled ?? (phone != null && phone.isNotEmpty);
    if (!enabled || phone == null || phone.isEmpty) {
      return null;
    }
    return RememberedCredentials(
      phone: phone,
      password: password ?? '',
      rememberMe: true,
    );
  }

  Future<void> clear() async {
    await _storage.delete(_rememberPhoneKey);
    await _storage.delete(_rememberPasswordKey);
    await _storage.delete(_rememberEnabledKey);
  }
}
