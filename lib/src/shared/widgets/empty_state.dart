import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Empty state with illustration, title, optional subtitle, and optional CTA.
///
/// Illustration priority (highest → lowest):
///  1. [lottieAsset] — looping Lottie animation at width 180
///  2. [svgAsset]    — SVG illustration at width 160
///  3. [icon]        — large [IconData] (original fallback)
///
/// ```dart
/// EmptyState(
///   lottieAsset: 'assets/lottie/lottie_empty_calendar.json',
///   title: 'No sessions booked',
///   subtitle: 'Book your first session to get started.',
///   action: PrimaryButton(label: 'Browse Sessions', onPressed: _browse),
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon,
    this.lottieAsset,
    this.svgAsset,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData? icon;

  /// Path to a Lottie JSON asset. Takes priority over [svgAsset] and [icon].
  final String? lottieAsset;

  /// Path to an SVG asset. Takes priority over [icon].
  final String? svgAsset;

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIllustration(mutedColor),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: titleColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.body.copyWith(color: mutedColor),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 48),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(Color iconColor) {
    if (lottieAsset != null) {
      return Lottie.asset(
        lottieAsset!,
        width: 180,
        height: 180,
        repeat: true,
        errorBuilder: (_, __, ___) =>
            Icon(icon ?? Icons.hourglass_empty, size: 64, color: iconColor),
      );
    }
    if (svgAsset != null) {
      return SvgPicture.asset(
        svgAsset!,
        width: 160,
        height: 160,
      );
    }
    return Icon(icon ?? Icons.hourglass_empty, size: 64, color: iconColor);
  }
}
