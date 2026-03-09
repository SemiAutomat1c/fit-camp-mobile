import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full-width brand CTA button with neon glow when enabled.
///
/// Shows a loading spinner in place of the label and icon when [isLoading]
/// is true. Disabled (no ripple, reduced opacity, no glow) when [onPressed]
/// is null or [isLoading] is true.
///
/// ```dart
/// PrimaryButton(
///   label: 'Book Session',
///   onPressed: _submit,
///   isLoading: state.isLoading,
///   icon: Icons.calendar_month,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.primary : AppColors.lightPrimary;
    final fgColor = AppColors.background;

    return AnimatedOpacity(
      opacity: _isEnabled ? 1.0 : 0.38,
      duration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: bgColor.withAlpha(115), // ~45% opacity
                    blurRadius: 18,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              disabledBackgroundColor: bgColor,
              disabledForegroundColor: fgColor,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: isLoading
                ? const _LoadingContent()
                : _LabelContent(label: label, icon: icon),
          ),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      ),
    );
  }
}

class _LabelContent extends StatelessWidget {
  const _LabelContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(label, style: AppTextStyles.button.copyWith(color: AppColors.background));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.background),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.button.copyWith(color: AppColors.background)),
      ],
    );
  }
}
