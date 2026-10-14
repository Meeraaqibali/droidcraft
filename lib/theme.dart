import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme-aware colors that flip automatically with dark / light mode.
class DC {
  static bool _dark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// Card / sheet surface.
  static Color surface(BuildContext c) =>
      _dark(c) ? const Color(0xFF1E293B) : Colors.white;

  /// Scaffold background.
  static Color bg(BuildContext c) =>
      _dark(c) ? const Color(0xFF0F172A) : const Color(0xFFF5F6FA);

  /// Primary text.
  static Color text(BuildContext c) =>
      _dark(c) ? const Color(0xFFF1F5F9) : const Color(0xFF111827);

  /// Muted / secondary text.
  static Color muted(BuildContext c) =>
      _dark(c) ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

  /// Borders and dividers.
  static Color border(BuildContext c) =>
      _dark(c) ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  /// Input fields, secondary surfaces.
  static Color inputFill(BuildContext c) =>
      _dark(c) ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB);

  /// Chip / tag backgrounds.
  static Color subtle(BuildContext c) =>
      _dark(c) ? const Color(0xFF334155) : const Color(0xFFF5F6FA);
}

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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      systemNavigationBarColor:
          isDark ? const Color(0xFF1E293B) : Colors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor:
          isDark ? const Color(0xFF1E293B) : Colors.white,
    );
  }

  /// Sets the status bar + system navigation bar to match the current theme.
  /// Call this whenever the theme mode changes.
  static void applySystemUi(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          isDark ? const Color(0xFF1E293B) : Colors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarDividerColor:
          isDark ? const Color(0xFF1E293B) : Colors.white,
    ));
  }

  /// Enables edge-to-edge drawing (nav bar sits on top of content).
  static Future<void> enableEdgeToEdge() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
}
