import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/simulation_models.dart';
import '../theme/app_theme.dart';

class ComparisonChart extends StatefulWidget {
  final SimulationInput input;
  final SimulationOutput output;

  const ComparisonChart({super.key, required this.input, required this.output});

  @override
  State<ComparisonChart> createState() => _ComparisonChartState();
}

class _ComparisonChartState extends State<ComparisonChart> {
  @override
  Widget build(BuildContext context) {
    final entries = widget.output.metalComparisons.isNotEmpty
        ? widget.output.metalComparisons
              .map(
                (m) => _BarEntry(
                  label: m.metalName,
                  c0: m.initialConc,
                  cf: m.finalConc,
                ),
              )
              .toList()
        : [
            _BarEntry(
              label: 'Contaminante',
              c0: widget.input.initialConcentration,
              cf: widget.output.averageFinalConcentration,
            ),
          ];

    final maxY =
        entries.map((e) => e.c0).fold<double>(0, (a, b) => a > b ? a : b) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparativa C₀ vs Cf',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: maxY <= 0 ? 1 : maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (v, m) => Text(
                          v.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= entries.length)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              entries[i].label,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < entries.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: entries[i].c0,
                            color: AppColors.danger.withOpacity(0.75),
                            width: 14,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: entries[i].cf,
                            color: AppColors.primary,
                            width: 14,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _LegendSwatch(
                  color: AppColors.danger.withOpacity(0.75),
                  label: 'C₀ — Inicial',
                ),
                const SizedBox(width: 16),
                _LegendSwatch(color: AppColors.primary, label: 'Cf — Final'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarEntry {
  final String label;
  final double c0;
  final double cf;
  _BarEntry({required this.label, required this.c0, required this.cf});
}

class _LegendSwatch extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendSwatch({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
