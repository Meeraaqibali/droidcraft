import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFEEF2FF);
  static const androidPrimary = Color(0xFF6200EE);
  static const danger = Color(0xFFEF4444);

  static const Map<String, String> fontOptions = {
    'Roboto (Default)': 'Roboto',
    'Serif': 'serif',
    'Monospace': 'monospace',
    'Condensed': 'sans-serif-condensed',
    'Cursive': 'cursive',
  };

  static ThemeData light(String font) => _build(font, Brightness.light);
  static ThemeData dark(String font) => _build(font, Brightness.dark);

  static ThemeData _build(String font, Brightness b) {
    final isDark = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      fontFamily: font,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: b),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F6FA),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
        elevation: 0.5,
        titleTextStyle: TextStyle(
          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF111827),
          fontSize: 17,
          fontWeight: FontWeight.w800,
          fontFamily: font,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }
}
