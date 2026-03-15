import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Circular countdown timer shown during rest periods between sets.
///
/// Animates a [CircularProgressIndicator] from 1.0 → 0.0 over [duration].
/// Calls [onComplete] and triggers [HapticFeedback.heavyImpact] when done.
/// [onSkip] is called when the user taps the skip button.
class RestTimer extends StatefulWidget {
  const RestTimer({
    super.key,
    this.duration = 60,
    required this.onComplete,
    required this.onSkip,
  });

  final int duration;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _secondsLeft;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
    _controller.forward();
  }

  void _onTick() {
    final elapsed = (_controller.value * widget.duration).round();
    final left = widget.duration - elapsed;
    if (left != _secondsLeft && mounted) {
      setState(() => _secondsLeft = left.clamp(0, widget.duration));
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_completed) {
      _completed = true;
      HapticFeedback.heavyImpact();
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = 1.0 - _controller.value;
            return SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Text(
                          '$_secondsLeft',
                          key: ValueKey<int>(_secondsLeft),
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'seconds',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: widget.onSkip,
          child: Text(
            'Skip Rest',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.primaryMuted),
          ),
        ),
      ],
    );
  }
}
