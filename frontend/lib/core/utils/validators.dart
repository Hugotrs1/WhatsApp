import '../../api/apiService.dart';

class Validators {
  Validators._();

  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Merci de renseigner $label.';
    }
    return null;
  }

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Merci de renseigner le téléphone.';
    }
    final normalized = ApiService.normalizePhone(trimmed);
    if (!RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'Numéro invalide.';
    }
    if (normalized.length != 10) {
      return 'Numéro invalide.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Merci de confirmer le mot de passe.';
    }
    if (value.trim() != password.trim()) {
      return 'Les mots de passe ne correspondent pas.';
    }
    return null;
  }
}
