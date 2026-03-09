import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';
import 'skeleton_text.dart';

/// Shimmer placeholder matching [AppCard] dimensions.
///
/// Base: `#111111` (surface) → highlight: `#1A1A1A` (elevated).
/// Contains three rows of [SkeletonText] to approximate typical card content.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.elevated,
      child: Container(
        width: double.infinity,
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            SkeletonText(height: 16, width: double.infinity),
            SizedBox(height: 8),
            SkeletonText(height: 12, widthFraction: 0.7),
            SizedBox(height: 6),
            SkeletonText(height: 12, widthFraction: 0.5),
          ],
        ),
      ),
    );
  }
}
