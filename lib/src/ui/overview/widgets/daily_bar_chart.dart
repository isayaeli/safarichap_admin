import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';

/// One series of daily values: thin bars in brand gold, rounded data-ends on
/// the baseline, a recessive grid and a per-bar hover tooltip. Days without
/// data are zero so the time axis stays continuous.
class DailyBarChart extends StatelessWidget {
  final DateTime start;
  final int days;
  final Map<DateTime, num> values;
  final String Function(num value) formatValue;
  final String Function(num value) formatAxis;

  const DailyBarChart({
    super.key,
    required this.start,
    required this.days,
    required this.values,
    required this.formatValue,
    required this.formatAxis,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dates = [
      for (var i = 0; i < days; i++)
        DateTime(start.year, start.month, start.day + i),
    ];
    final maxValue = values.values.fold<num>(0, (a, b) => b > a ? b : a);
    final labelEvery = days <= 14 ? 2 : (days <= 31 ? 7 : 14);
    final barWidth = (600 / days).clamp(3, 14).toDouble();
    final muted = TextStyle(fontSize: 11, color: scheme.onSurfaceVariant);

    return BarChart(
      BarChartData(
        maxY: maxValue == 0 ? 1 : maxValue * 1.15,
        alignment: BarChartAlignment.spaceBetween,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) return const SizedBox.shrink();
                return Text(formatAxis(value), style: muted);
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i % labelEvery != 0 || i >= dates.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(TimeUtil.formatShortDate(dates[i]), style: muted),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            tooltipBorderRadius: BorderRadius.circular(6),
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${TimeUtil.formatDate(dates[group.x])}\n',
              TextStyle(color: scheme.onInverseSurface, fontSize: 11),
              children: [
                TextSpan(
                  text: formatValue(rod.toY),
                  style: TextStyle(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        barGroups: [
          for (final (i, d) in dates.indexed)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (values[d] ?? 0).toDouble(),
                  width: barWidth,
                  color: safariChapColors.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
