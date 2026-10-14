import 'package:flutter/material.dart';

/// Slide in from the right — default for forward navigation.
Route<T> slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: a.drive(tween),
        child: FadeTransition(opacity: a, child: child),
      );
    },
  );
}

/// Slide up from bottom — good for sheets / full-screen modals.
Route<T> slideUpRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) {
      final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: a.drive(tween),
        child: FadeTransition(opacity: a, child: child),
      );
    },
  );
}

/// Fade only — subtle.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
  );
}

/// Scale + fade — a bit playful.
Route<T> scaleRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) {
      final scale = Tween(begin: 0.94, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: a.drive(scale), child: child),
      );
    },
  );
}
