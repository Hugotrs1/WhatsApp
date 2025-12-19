import 'package:flutter/material.dart';

import 'app_theme.dart';

class WhatsAppStyles {
  WhatsAppStyles._();

  static const Color primaryColor = AppTheme.brandMid;
  static const Color backgroundColor = AppTheme.brandLight;

  static const Color mutedTextColor = AppTheme.muted;
  static const Color dividerColor = AppTheme.divider;
  static const Color searchFillColor = AppTheme.searchFill;

  static const EdgeInsets pagePadding = EdgeInsets.all(20);
  static const EdgeInsets authFormPadding = EdgeInsets.all(20);
  static const EdgeInsets authFormCompactPadding = EdgeInsets.all(10);

  static const BorderRadius fieldBorderRadius = AppTheme.fieldBorderRadius;
  static const BorderRadius cardBorderRadius = AppTheme.cardBorderRadius;
  static const BorderRadius searchBorderRadius = AppTheme.searchBorderRadius;
  static const BorderRadius composerBorderRadius = AppTheme.composerBorderRadius;

  static OutlineInputBorder outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: fieldBorderRadius,
      borderSide: BorderSide(color: color),
    );
  }

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: cardBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.accent,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: const RoundedRectangleBorder(borderRadius: fieldBorderRadius),
  );

  static InputDecoration formFieldDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      border: outlineBorder(dividerColor),
      focusedBorder: outlineBorder(AppTheme.accent),
    );
  }

  static InputDecoration dropdownDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      border: outlineBorder(dividerColor),
      focusedBorder: outlineBorder(AppTheme.accent),
    );
  }

  static InputDecoration searchFieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: searchBorderRadius,
        borderSide: BorderSide(color: dividerColor),
      ),
      filled: true,
      fillColor: searchFillColor,
    );
  }

  static final BoxDecoration messageComposerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: composerBorderRadius,
    border: Border.all(color: dividerColor),
  );

  static const InputDecoration messageInputDecoration = InputDecoration(
    hintText: 'Message',
    border: InputBorder.none,
  );

  static TextStyle? brandTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.brandMid,
        );
  }

  static TextStyle? mutedBodyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: mutedTextColor,
        );
  }
}
