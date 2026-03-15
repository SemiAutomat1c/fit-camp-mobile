import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/progress_log.dart';

/// LineChart showing weight over time using fl_chart.
///
/// Requires at least 2 data points to render the chart. Shows a trend delta
/// chip (↓ / ↑) above the chart comparing the two most recent entries.
///
/// If [goalWeight] is provided, a dashed horizontal line is drawn at that
/// weight value using [ExtraLinesData].
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.logs, this.goalWeight});

  final List<ProgressLog> logs;

  /// Optional goal weight target line (dashed, in AppColors.primaryMuted).
  final double? goalWeight;

  @override
  Widget build(BuildContext context) {
    final withWeight =
        logs.where((l) => l.weight != null).toList().reversed.toList();

    if (withWeight.length < 2) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          'Log more entries to see weight trends',
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    final spots = withWeight.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight!);
    }).toList();

    final weights = withWeight.map((l) => l.weight!).toList();
    final minY =
        (weights.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
    final maxY =
        (weights.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

    final dateFormat = DateFormat('d MMM');

    String labelForIndex(int idx) {
      if (idx < 0 || idx >= withWeight.length) return '';
      return dateFormat.format(withWeight[idx].date);
    }

    final count = withWeight.length;
    final midIdx = count ~/ 2;

    // Trend delta: compare last two logged weights
    final latestW = withWeight.last.weight!;
    final prevW = withWeight[withWeight.length - 2].weight!;
    final delta = latestW - prevW;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trend chip
        _TrendChip(delta: delta),
        const SizedBox(height: 8),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(15),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (count - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              extraLinesData: goalWeight != null
                  ? ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: goalWeight!,
                          color: AppColors.primaryMuted,
                          strokeWidth: 1.5,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            labelResolver: (_) => 'Goal',
                            style: const TextStyle(
                              color: AppColors.primaryMuted,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: const Color(0xFF222222),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: (maxY - minY) / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx == 0 || idx == midIdx || idx == count - 1) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labelForIndex(idx),
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final idx = spot.x.toInt();
                      final label = labelForIndex(idx);
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)} kg\n$label',
                        AppTextStyles.label
                            .copyWith(color: AppColors.textPrimary),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.primary,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withAlpha(77),
                        AppColors.primary.withAlpha(0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.delta});

  final double delta;

  @override
  Widget build(BuildContext context) {
    final isDown = delta <= 0;
    final color = isDown ? AppColors.primary : AppColors.warning;
    final icon = isDown ? '↓' : '↑';
    final label =
        '$icon ${delta.abs().toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color),
      ),
    );
  }
}
