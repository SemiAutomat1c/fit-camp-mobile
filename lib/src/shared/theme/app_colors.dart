import 'package:flutter/material.dart';

/// Brand color palette for 24 Fit Camp.
///
/// Dark theme is the default. Light theme uses [AppColors.light*] variants.
/// Do not use [AppColors.primary] (#39FF14) on white — it fails WCAG AA.
/// Use [AppColors.lightPrimary] (#2DB80F) for light theme CTAs.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Dark theme (default)
  // ---------------------------------------------------------------------------

  /// `#0A0A0A` — brand-black, main background (zero-power OLED)
  static const Color background = Color(0xFF0A0A0A);

  /// `#111111` — card / surface background
  static const Color surface = Color(0xFF111111);

  /// `#1A1A1A` — modals, bottom sheets, elevated surfaces
  static const Color elevated = Color(0xFF1A1A1A);

  /// `#222222` — dividers and borders
  static const Color border = Color(0xFF222222);

  /// `#39FF14` — neon green; CTAs, active states, focus rings (dark theme only)
  static const Color primary = Color(0xFF39FF14);

  /// `#7EC820` — muted green for secondary accents
  static const Color primaryMuted = Color(0xFF7EC820);

  /// `#FFFFFF` — primary text on dark backgrounds
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// `#A1A1AA` — secondary / hint text on dark backgrounds
  static const Color textMuted = Color(0xFFA1A1AA);

  /// `#EF4444` — error state
  static const Color error = Color(0xFFEF4444);

  /// `#22C55E` — success state
  static const Color success = Color(0xFF22C55E);

  /// `#F59E0B` — warning state
  static const Color warning = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  /// `#F5F5F5` — light theme background
  static const Color lightBackground = Color(0xFFF5F5F5);

  /// `#FFFFFF` — light theme card / surface
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// `#EEEEEE` — light theme elevated surface
  static const Color lightElevated = Color(0xFFEEEEEE);

  /// `#DDDDDD` — light theme borders
  static const Color lightBorder = Color(0xFFDDDDDD);

  /// `#2DB80F` — darker green; WCAG AA compliant on white backgrounds
  static const Color lightPrimary = Color(0xFF2DB80F);

  /// `#0A0A0A` — primary text on light backgrounds
  static const Color lightTextPrimary = Color(0xFF0A0A0A);

  /// `#555555` — secondary / hint text on light backgrounds
  static const Color lightTextMuted = Color(0xFF555555);
}
