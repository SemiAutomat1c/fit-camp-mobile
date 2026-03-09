import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';

/// Single shimmer line used as a text placeholder.
///
/// Use [width] for a fixed pixel width or [widthFraction] (0.0–1.0) for a
/// fraction of the available width via [LayoutBuilder].
/// One of [width] or [widthFraction] should be provided; if neither is set,
/// the line fills full available width.
///
/// ```dart
/// SkeletonText(height: 14, widthFraction: 0.6)
/// SkeletonText(height: 12, width: 120)
/// ```
class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    this.height = 14,
    this.width,
    this.widthFraction,
  }) : assert(
          width == null || widthFraction == null,
          'Provide either width or widthFraction, not both.',
        );

  final double height;

  /// Fixed pixel width. Mutually exclusive with [widthFraction].
  final double? width;

  /// Fraction of the parent width (0.0–1.0). Mutually exclusive with [width].
  final double? widthFraction;

  @override
  Widget build(BuildContext context) {
    if (widthFraction != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return _ShimmerLine(
            width: constraints.maxWidth * widthFraction!,
            height: height,
          );
        },
      );
    }
    return _ShimmerLine(
      width: width ?? double.infinity,
      height: height,
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.elevated,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
    );
  }
}
