import 'package:flutter/material.dart';
import '../models/simulation_models.dart';
import '../theme/app_theme.dart';

class KpiCards extends StatelessWidget {
  final SimulationOutput output;
  final String unit;

  const KpiCards({super.key, required this.output, required this.unit});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiData(
        title: 'Eficiencia Promedio de Remoción',
        value: '${output.averageRemovalEfficiency.toStringAsFixed(1)}%',
        subtitle: 'Promedio general de la simulación',
        icon: Icons.filter_alt_outlined,
        color: AppColors.primary,
      ),
      _KpiData(
        title: 'Concentración Final Promedio',
        value: output.averageFinalConcentration.toStringAsFixed(3),
        subtitle: unit,
        icon: Icons.water_drop_outlined,
        color: AppColors.accent,
      ),
      _KpiData(
        title: 'Recuperación Magnética del Biochar',
        value: '${output.magneticRecovery.toStringAsFixed(1)}%',
        subtitle: 'Extracción con campo magnético externo',
        icon: Icons.grain_outlined,
        color: AppColors.magnetic,
      ),
      _KpiData(
        title: 'Conservación de Eficiencia',
        value: '${output.reusabilityEfficiency3Cycles.toStringAsFixed(1)}%',
        subtitle: 'Estimado tras 3 ciclos de reutilización',
        icon: Icons.recycling_outlined,
        color: AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final crossAxisCount = isWide
            ? 4
            : (constraints.maxWidth > 420 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 130,
          ),
          itemBuilder: (context, i) => _KpiCard(data: cards[i]),
        );
      },
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(data.icon, color: data.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: data.color,
                    fontSize: 24,
                  ),
                ),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
