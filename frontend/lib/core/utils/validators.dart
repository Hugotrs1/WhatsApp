import '../../api/apiService.dart';

class Validators {
  Validators._();

  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label.';
    }
    return null;
  }

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter a phone number.';
    }
    final normalized = ApiService.normalizePhone(trimmed);
    if (!RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'Invalid number.';
    }
    if (normalized.length != 10) {
      return 'Invalid number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm the password.';
    }
    if (value.trim() != password.trim()) {
      return 'Passwords do not match.';
    }
    return null;
  }
}
