import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for 24 Fit Camp.
///
/// Headings use Barlow Condensed (condensed, bold, athletic feel).
/// Body / UI text uses Inter (legible, modern sans-serif).
///
/// All styles are color-neutral — apply color at the call site via
/// [TextStyle.copyWith] or [DefaultTextStyle]. This keeps styles reusable
/// across dark and light themes without duplication.
abstract final class AppTextStyles {
  /// 36 / 700 / 1.2h — screen-level headings (Barlow Condensed)
  static TextStyle get heading1 => GoogleFonts.barlowCondensed(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  /// 26 / 700 / 1.25h — section headings (Barlow Condensed)
  static TextStyle get heading2 => GoogleFonts.barlowCondensed(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// 22 / 600 / 1.3h — card titles, modal headers (Barlow Condensed)
  static TextStyle get heading3 => GoogleFonts.barlowCondensed(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  /// 19 / 600 / 1.35h — sub-section titles (Barlow Condensed)
  static TextStyle get heading4 => GoogleFonts.barlowCondensed(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  /// 16 / 400 / 1.5h — standard body copy (Inter)
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// 16 / 500 / 1.5h — emphasized body copy (Inter)
  static TextStyle get bodyMed => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  /// 14 / 400 / 1.4h — captions, timestamps, helper text (Inter)
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  /// 12 / 500 / 1.3h / 0.5ls — overline labels, tags, badges (Inter)
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.5,
      );

  /// 16 / 600 / 1.0h / 0.25ls — button text (Inter)
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.25,
      );
}
