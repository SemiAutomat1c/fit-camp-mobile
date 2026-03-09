import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Theme factory for 24 Fit Camp.
///
/// Provides [dark] (default) and [light] Material 3 [ThemeData] instances.
/// Configure [MaterialApp.theme], [MaterialApp.darkTheme], and
/// [MaterialApp.themeMode] at the app root.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Dark theme (default)
  // ---------------------------------------------------------------------------

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.background,
      primaryContainer: Color(0xFF1A3A0A),
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primaryMuted,
      onSecondary: AppColors.background,
      secondaryContainer: Color(0xFF152D05),
      onSecondaryContainer: AppColors.primaryMuted,
      tertiary: AppColors.success,
      onTertiary: AppColors.background,
      tertiaryContainer: Color(0xFF0A2A14),
      onTertiaryContainer: AppColors.success,
      error: AppColors.error,
      onError: AppColors.textPrimary,
      errorContainer: Color(0xFF3A0A0A),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textMuted,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.lightTextPrimary,
      inversePrimary: AppColors.lightPrimary,
      surfaceContainerHighest: AppColors.elevated,
      surfaceContainerHigh: AppColors.elevated,
      surfaceContainer: AppColors.surface,
      surfaceContainerLow: AppColors.surface,
      surfaceContainerLowest: AppColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        constraints: BoxConstraints(minHeight: 56),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 16),
        labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 16),
        floatingLabelStyle: TextStyle(color: AppColors.primary, fontSize: 12),
        errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
      ),
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          elevation: 0,
          textStyle: AppTextStyles.button,
          disabledBackgroundColor: AppColors.primary.withAlpha(97),
          disabledForegroundColor: AppColors.background.withAlpha(153),
        ),
      ),
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primary.withAlpha(51),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label.copyWith(color: AppColors.primary);
          }
          return AppTextStyles.label.copyWith(color: AppColors.textMuted);
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.elevated,
        modalBackgroundColor: AppColors.elevated,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.border,
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      // Icon
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      // Text
      textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textMuted),
    );
  }

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightSurface,
      primaryContainer: Color(0xFFD4F4C8),
      onPrimaryContainer: Color(0xFF0A3A02),
      secondary: AppColors.primaryMuted,
      onSecondary: AppColors.lightSurface,
      secondaryContainer: Color(0xFFE8F5D8),
      onSecondaryContainer: Color(0xFF152D05),
      tertiary: AppColors.success,
      onTertiary: AppColors.lightSurface,
      tertiaryContainer: Color(0xFFC8F0D8),
      onTertiaryContainer: Color(0xFF0A2A14),
      error: AppColors.error,
      onError: AppColors.lightSurface,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextMuted,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
      shadow: Colors.black12,
      scrim: Colors.black38,
      inverseSurface: AppColors.surface,
      onInverseSurface: AppColors.textPrimary,
      inversePrimary: AppColors.primary,
      surfaceContainerHighest: AppColors.lightElevated,
      surfaceContainerHigh: AppColors.lightElevated,
      surfaceContainer: AppColors.lightSurface,
      surfaceContainerLow: AppColors.lightSurface,
      surfaceContainerLowest: AppColors.lightBackground,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
          height: 1.3,
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        constraints: BoxConstraints(minHeight: 56),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(color: AppColors.lightTextMuted, fontSize: 16),
        labelStyle: TextStyle(color: AppColors.lightTextMuted, fontSize: 16),
        floatingLabelStyle: TextStyle(
          color: AppColors.lightPrimary,
          fontSize: 12,
        ),
        errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
      ),
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightSurface,
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          elevation: 0,
          textStyle: AppTextStyles.button,
          disabledBackgroundColor: AppColors.lightPrimary.withAlpha(97),
          disabledForegroundColor: AppColors.lightSurface.withAlpha(153),
        ),
      ),
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size(48, 48),
          textStyle: AppTextStyles.button,
        ),
      ),
      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        elevation: 0,
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightPrimary.withAlpha(51),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightPrimary, size: 24);
          }
          return IconThemeData(color: AppColors.lightTextMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.label.copyWith(color: AppColors.lightPrimary);
          }
          return AppTextStyles.label.copyWith(color: AppColors.lightTextMuted);
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightElevated,
        modalBackgroundColor: AppColors.lightElevated,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.lightBorder,
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      // Icon
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      // Text
      textTheme: _buildTextTheme(
        AppColors.lightTextPrimary,
        AppColors.lightTextMuted,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static TextTheme _buildTextTheme(Color primary, Color muted) {
    return TextTheme(
      displayLarge: AppTextStyles.heading1.copyWith(color: primary),
      displayMedium: AppTextStyles.heading2.copyWith(color: primary),
      displaySmall: AppTextStyles.heading3.copyWith(color: primary),
      headlineLarge: AppTextStyles.heading1.copyWith(color: primary),
      headlineMedium: AppTextStyles.heading2.copyWith(color: primary),
      headlineSmall: AppTextStyles.heading3.copyWith(color: primary),
      titleLarge: AppTextStyles.heading3.copyWith(color: primary),
      titleMedium: AppTextStyles.heading4.copyWith(color: primary),
      titleSmall: AppTextStyles.bodyMed.copyWith(color: primary),
      bodyLarge: AppTextStyles.body.copyWith(color: primary),
      bodyMedium: AppTextStyles.caption.copyWith(color: primary),
      bodySmall: AppTextStyles.label.copyWith(color: muted),
      labelLarge: AppTextStyles.button.copyWith(color: primary),
      labelMedium: AppTextStyles.label.copyWith(color: muted),
      labelSmall: AppTextStyles.label.copyWith(color: muted, fontSize: 11),
    );
  }
}
