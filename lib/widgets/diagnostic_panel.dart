import 'package:flutter/material.dart';
import '../models/simulation_models.dart';
import '../theme/app_theme.dart';

class DiagnosticPanel extends StatelessWidget {
  final SimulationOutput output;

  const DiagnosticPanel({super.key, required this.output});

  @override
  Widget build(BuildContext context) {
    // Separa las conclusiones por párrafos para mostrarlos bien estructurados
    final parrafos = output.diagnosticMessage
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Card(
      color: AppColors.primary.withOpacity(0.06),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.insights_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnóstico y Conclusiones Automáticas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < parrafos.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == parrafos.length - 1 ? 0 : 10,
                      ),
                      child: Text(
                        parrafos[i],
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
