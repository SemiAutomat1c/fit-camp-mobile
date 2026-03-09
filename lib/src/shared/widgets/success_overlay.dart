import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Full-screen success overlay with a Lottie animation.
///
/// Shows a semi-transparent backdrop, a Lottie animation, and an optional
/// [message]. Auto-dismisses after the animation completes (or after
/// [autoDismissDelay], whichever is shorter).
///
/// Usage — show on top of a page after a successful action:
/// ```dart
/// await showSuccessOverlay(
///   context,
///   assetPath: 'assets/lottie/success_check.json',
///   message: 'Session booked!',
/// );
/// ```
Future<void> showSuccessOverlay(
  BuildContext context, {
  required String assetPath,
  String? message,
  Duration autoDismissDelay = const Duration(milliseconds: 1600),
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withAlpha(153), // 60%
    barrierDismissible: false,
    builder: (ctx) => _SuccessOverlay(
      assetPath: assetPath,
      message: message,
      autoDismissDelay: autoDismissDelay,
    ),
  );
}

class _SuccessOverlay extends StatefulWidget {
  const _SuccessOverlay({
    required this.assetPath,
    this.message,
    required this.autoDismissDelay,
  });

  final String assetPath;
  final String? message;
  final Duration autoDismissDelay;

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.autoDismissDelay, () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            widget.assetPath,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            repeat: false,
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.message!,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
