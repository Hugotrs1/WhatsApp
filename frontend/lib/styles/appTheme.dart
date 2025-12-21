import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color brandDark = Color(0xFF062B2D);
  static const Color brandMid = Color(0xFF0F6B5F);
  static const Color brandLight = Color(0xFFEFFAF6);
  static const Color accent = Color(0xFF12C2A3);
  static const Color accentDark = Color(0xFF0B8C70);
  static const Color unread = Color(0xFF06CE9A);
  static const Color muted = Color(0xFF7C8A87);
  static const Color divider = Color(0xFFE3EAE8);
  static const Color fieldFill = Color(0xEBFFFFFF);
  static const Color searchFill = Color(0xFFF4F8F6);
  static const Color tabMuted = Color(0xFF355A56);
  static const Color cardBorder = Color(0x66FFFFFF);
  static const Color chipBorder = Color(0x33FFFFFF);

  static const BorderRadius fieldBorderRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(28));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius searchBorderRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius composerBorderRadius = BorderRadius.all(Radius.circular(24));

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, accentDark],
  );

  static ThemeData lightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: brandMid,
        secondary: accent,
        background: brandLight,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: brandLight,
    );

    final textTheme = GoogleFonts.soraTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: brandDark,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: brandMid,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      dividerColor: divider,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brandDark,
        contentTextStyle: GoogleFonts.sora(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.sora(
          fontWeight: FontWeight.w600,
          color: brandDark.withOpacity(0.65),
        ),
        floatingLabelStyle: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          color: accentDark,
        ),
        prefixIconColor: brandDark.withOpacity(0.7),
        suffixIconColor: brandDark.withOpacity(0.7),
        border: const OutlineInputBorder(
          borderRadius: fieldBorderRadius,
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: fieldBorderRadius,
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: fieldBorderRadius,
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: buttonBorderRadius),
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentDark,
          textStyle: GoogleFonts.sora(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: brandMid,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandMid,
        foregroundColor: Colors.white,
      ),
    );
  }
}
