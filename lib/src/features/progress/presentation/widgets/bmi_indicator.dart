import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Horizontal colored BMI range bar with an animated position marker.
///
/// The triangle marker slides in from the left on first render
/// (600 ms, [Curves.elasticOut]).
///
/// Sections:
///  - < 18.5  : Underweight (amber)
///  - 18.5–25 : Normal (green)
///  - 25–30   : Overweight (amber)
///  - ≥ 30    : Obese (red)
class BmiIndicator extends StatefulWidget {
  const BmiIndicator({super.key, required this.bmi});

  final double? bmi;

  @override
  State<BmiIndicator> createState() => _BmiIndicatorState();
}

class _BmiIndicatorState extends State<BmiIndicator>
    with SingleTickerProviderStateMixin {
  static const double _minBmi = 10.0;
  static const double _maxBmi = 40.0;

  late final AnimationController _controller;
  late final Animation<double> _fractionAnim;

  double _targetFraction(double bmi) {
    final clamped = bmi.clamp(_minBmi, _maxBmi);
    return (clamped - _minBmi) / (_maxBmi - _minBmi);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final target = widget.bmi != null ? _targetFraction(widget.bmi!) : 0.0;
    _fractionAnim = Tween<double>(begin: 0.0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.bmi != null) _controller.forward();
  }

  @override
  void didUpdateWidget(BmiIndicator old) {
    super.didUpdateWidget(old);
    if (old.bmi != widget.bmi && widget.bmi != null) {
      final target = _targetFraction(widget.bmi!);
      _fractionAnim = Tween<double>(
        begin: _fractionAnim.value,
        end: target,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _categoryLabel(double value) {
    if (value < 18.5) return 'Underweight';
    if (value < 25.0) return 'Normal';
    if (value < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color _categoryColor(double value) {
    if (value < 18.5) return AppColors.warning;
    if (value < 25.0) return AppColors.success;
    if (value < 30.0) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bmi == null) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            'No BMI data yet',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final value = widget.bmi!;
    final category = _categoryLabel(value);
    final markerColor = _categoryColor(value);

    return SizedBox(
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;

              return SizedBox(
                height: 36,
                child: AnimatedBuilder(
                  animation: _fractionAnim,
                  builder: (context, _) {
                    final markerX =
                        (_fractionAnim.value * totalWidth).clamp(6.0, totalWidth - 6.0);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Colored bar segments
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Row(
                              children: [
                                // Underweight: 10–18.5
                                Flexible(
                                  flex: _segmentFlex(10, 18.5),
                                  child: Container(color: AppColors.warning),
                                ),
                                // Normal: 18.5–25
                                Flexible(
                                  flex: _segmentFlex(18.5, 25.0),
                                  child: Container(color: AppColors.success),
                                ),
                                // Overweight: 25–30
                                Flexible(
                                  flex: _segmentFlex(25.0, 30.0),
                                  child: Container(color: AppColors.warning),
                                ),
                                // Obese: 30–40
                                Flexible(
                                  flex: _segmentFlex(30.0, 40.0),
                                  child: Container(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Triangle marker
                        Positioned(
                          left: markerX - 6,
                          top: 0,
                          child: _TriangleMarker(color: markerColor),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            '$category (${value.toStringAsFixed(1)})',
            style: AppTextStyles.label.copyWith(color: markerColor),
          ),
        ],
      ),
    );
  }

  /// Returns a flex integer proportional to the segment's BMI range width.
  int _segmentFlex(double start, double end) =>
      ((end - start) * 10).round();
}

class _TriangleMarker extends StatelessWidget {
  const _TriangleMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _TrianglePainter(color: color),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
