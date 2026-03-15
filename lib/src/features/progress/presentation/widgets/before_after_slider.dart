import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Side-by-side before/after image comparison slider.
///
/// Drag the center handle horizontally to reveal more of either image.
/// The "before" image is clipped to the left of the divider;
/// the "after" image is clipped to the right.
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    super.key,
    required this.beforeUrl,
    required this.afterUrl,
  });

  final String beforeUrl;
  final String afterUrl;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _dividerFraction = 0.5;

  static const double _handleWidth = 3.0;
  static const double _handleIconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final dividerX = totalWidth * _dividerFraction;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dividerFraction =
                  (_dividerFraction + details.delta.dx / totalWidth)
                      .clamp(0.05, 0.95);
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                children: [
                  // "After" image fills the full width (bottom layer)
                  Positioned.fill(
                    child: _NetworkImage(url: widget.afterUrl),
                  ),
                  // "Before" image clipped to the left
                  Positioned.fill(
                    child: ClipRect(
                      clipper: _SideClipper(
                        fraction: _dividerFraction,
                        clipRight: false,
                      ),
                      child: _NetworkImage(url: widget.beforeUrl),
                    ),
                  ),
                  // Labels
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _Label(text: 'Before'),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: _Label(text: 'After'),
                  ),
                  // Divider line
                  Positioned(
                    left: dividerX - _handleWidth / 2,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: _handleWidth,
                      color: Colors.white,
                    ),
                  ),
                  // Drag handle
                  Positioned(
                    left: dividerX - 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(77),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.unfold_more_rounded,
                          size: _handleIconSize,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _SideClipper extends CustomClipper<Rect> {
  const _SideClipper({required this.fraction, required this.clipRight});

  final double fraction;

  /// If true, clips to the right side of the divider.
  /// If false, clips to the left side.
  final bool clipRight;

  @override
  Rect getClip(Size size) {
    if (clipRight) {
      return Rect.fromLTWH(
        size.width * fraction,
        0,
        size.width * (1 - fraction),
        size.height,
      );
    }
    return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(_SideClipper old) => old.fraction != fraction;
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.elevated,
        child: Container(color: AppColors.surface),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surface,
        child: const Icon(Icons.broken_image,
            color: AppColors.textMuted, size: 40),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(153),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: Colors.white),
      ),
    );
  }
}
