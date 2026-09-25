import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/simulation_models.dart';
import '../theme/app_theme.dart';

class KineticsChart extends StatelessWidget {
  final SimulationOutput output;

  const KineticsChart({super.key, required this.output});

  @override
  Widget build(BuildContext context) {
    final curva = output.kineticCurve;
    final maxY = curva.isNotEmpty
        ? curva.map((p) => p.upperBound).reduce((a, b) => a > b ? a : b) * 1.25
        : 10.0;

    final promedioSpots = curva
        .map((p) => FlSpot(p.time, p.meanConcentration))
        .toList();
    final bandaAltaSpots = curva
        .map((p) => FlSpot(p.time, p.upperBound))
        .toList();
    final bandaBajaSpots = curva
        .map((p) => FlSpot(p.time, p.lowerBound))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cinética de Adsorción — Promedio de las Corridas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Concentración (mg/L) vs. Tiempo (min)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY <= 0 ? 1 : maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${value.toInt()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: bandaAltaSpots,
                      isCurved: true,
                      color: AppColors.accent.withOpacity(0.0),
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.accent.withOpacity(0.12),
                        cutOffY: 0,
                        applyCutOffY: false,
                      ),
                    ),
                    LineChartBarData(
                      spots: bandaBajaSpots,
                      isCurved: true,
                      color: Colors.transparent,
                      barWidth: 0,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.background,
                        cutOffY: 0,
                        applyCutOffY: false,
                      ),
                    ),
                    LineChartBarData(
                      spots: promedioSpots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots
                          .map(
                            (s) => LineTooltipItem(
                              '${s.y.toStringAsFixed(2)} mg/L\n@ ${s.x.toStringAsFixed(0)} min',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Reemplaza el Row(...) final de la leyenda por un Wrap:
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _LegendDot(
                  color: AppColors.primary,
                  label: 'Curva promedio de remoción',
                ),
                _LegendDot(
                  color: AppColors.accent.withOpacity(0.4),
                  label: 'Banda de dispersión (corridas)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
