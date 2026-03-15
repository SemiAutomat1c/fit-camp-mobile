import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../shared/theme/app_colors.dart';

/// Three animated dots showing that the other participant is typing.
///
/// Each dot bounces in a staggered sequence using [flutter_animate].
/// The entire row fades in/out based on [isVisible].
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key, required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(right: index < 2 ? 5 : 0),
              child: _Dot(delayMs: index * 160),
            );
          }),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.delayMs});

  final int delayMs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.textMuted,
        shape: BoxShape.circle,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .slideY(
          begin: 0,
          end: -0.6,
          duration: const Duration(milliseconds: 420),
          delay: Duration(milliseconds: delayMs),
          curve: Curves.easeInOut,
        )
        .fadeIn(
          duration: const Duration(milliseconds: 200),
          delay: Duration(milliseconds: delayMs),
        );
  }
}
