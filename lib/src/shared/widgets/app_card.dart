import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard brand surface card with optional press-scale animation.
///
/// When [onTap] is provided the card scales down to 0.97x on press
/// (80 ms easeInOut) and springs back (120 ms easeOut), giving tactile
/// feedback. A brand-green splash at 8% opacity is also shown.
///
/// Pass [backgroundGradient] to overlay a gradient on top of the surface
/// color — use [kNeonTintGradient] for the standard neon tint.
///
/// ```dart
/// AppCard(
///   onTap: () => _openDetail(item),
///   backgroundGradient: kNeonTintGradient,
///   child: Text(item.title),
/// )
/// ```
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundGradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Optional gradient overlaid on the surface color.
  /// All existing callers are unaffected (null = original behavior).
  final LinearGradient? backgroundGradient;

  @override
  State<AppCard> createState() => _AppCardState();
}

/// Standard neon tint gradient — ~4% neon green fading top-left to transparent.
const LinearGradient kNeonTintGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0x0A39FF14), Color(0x00000000)],
);

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (_pressed) setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final primaryColor = isDark ? AppColors.primary : AppColors.lightPrimary;

    final cardContent = Padding(
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: widget.child,
    );

    final shell = _CardShell(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      backgroundGradient: widget.backgroundGradient,
      child: widget.onTap == null
          ? cardContent
          : InkWell(
              onTap: widget.onTap,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              splashColor: primaryColor.withAlpha(20),
              highlightColor: primaryColor.withAlpha(10),
              child: cardContent,
            ),
    );

    if (widget.onTap == null) return shell;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: _pressed
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 120),
        curve: _pressed ? Curves.easeInOut : Curves.easeOut,
        child: shell,
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    required this.surfaceColor,
    required this.borderColor,
    this.backgroundGradient,
  });

  final Widget child;
  final Color surfaceColor;
  final Color borderColor;
  final LinearGradient? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: backgroundGradient == null
            ? child
            : Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: backgroundGradient),
                    ),
                  ),
                  child,
                ],
              ),
      ),
    );
  }
}
