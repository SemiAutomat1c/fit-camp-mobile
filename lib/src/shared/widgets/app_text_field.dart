import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Brand-styled text input using [TextFormField].
///
/// Dark theme: `#111111` fill, `#222222` unfocused border, `#39FF14` focused.
/// Light theme: white fill, `#DDDDDD` unfocused border, `#2DB80F` focused.
///
/// Place inside a [Form] widget and provide a [GlobalKey<FormState>] to
/// trigger [validator] on submit.
///
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'you@example.com',
///   controller: _emailController,
///   keyboardType: TextInputType.emailAddress,
///   textInputAction: TextInputAction.next,
///   validator: (v) => v!.isEmpty ? 'Required' : null,
/// )
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.suffixIcon,
    this.enabled = true,
    this.maxLength,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field (e.g. taps "Next" or "Done").
  /// Use with [focusNode] to advance focus programmatically in multi-field forms.
  final ValueChanged<String>? onFieldSubmitted;

  /// Optional focus node for programmatic focus management in forms.
  final FocusNode? focusNode;

  final Widget? suffixIcon;
  final bool enabled;

  /// Maximum number of characters allowed. Shows a counter when set.
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final focusColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    final border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: borderColor, width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: focusColor, width: 2),
    );
    final errorBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      enabled: enabled,
      validator: validator,
      maxLength: maxLength,
      style: AppTextStyles.body.copyWith(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: enabled ? fillColor : fillColor.withAlpha(128),
        hintStyle: AppTextStyles.body.copyWith(color: hintColor),
        labelStyle: AppTextStyles.body.copyWith(color: hintColor),
        floatingLabelStyle: AppTextStyles.caption.copyWith(color: focusColor),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        constraints: const BoxConstraints(minHeight: 56),
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: borderColor.withAlpha(128), width: 1),
        ),
      ),
    );
  }
}
