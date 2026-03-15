import 'package:flutter/material.dart';

import 'app_card.dart';

/// Thin wrapper around [AppCard] with a neon tint gradient baked in.
///
/// The gradient is a very subtle neon green fade (top-left → transparent)
/// layered over the standard surface color. [gradientOpacity] controls
/// the peak alpha of the neon color (default 0.06 = ~6%).
class NeonGradientCard extends StatelessWidget {
  const NeonGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradientOpacity = 0.06,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Peak opacity of the neon green tint (0.0–1.0). Default: 0.06.
  final double gradientOpacity;

  @override
  Widget build(BuildContext context) {
    final alpha = (gradientOpacity * 255).round().clamp(0, 255);
    return AppCard(
      padding: padding,
      onTap: onTap,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(alpha, 0x39, 0xFF, 0x14),
          Colors.transparent,
        ],
      ),
      child: child,
    );
  }
}
