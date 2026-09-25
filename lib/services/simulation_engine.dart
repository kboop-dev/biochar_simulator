import 'dart:math';
import '../models/simulation_models.dart';

/// Motor de simulación para el proceso de adsorción en biochar.
/// Genera corridas estocásticas Monte Carlo y evalúa el diagnóstico
/// de forma 100% dinámica para la toma de decisiones.
class SimulationEngine {
  static final Random _rng = Random();

  static SimulationOutput run(SimulationInput input) {
    // 1. Configuración de parámetros por tipo de contaminante
    double baseK = 0.03;
    double maxEfficiency = 92.0; // % máximo teórico
    double optimalPh = 7.0;
    String contaminantName = 'Contaminante';

    switch (input.contaminantType) {
      case ContaminantType.arsenic:
        baseK = 0.035;
        maxEfficiency = 95.0;
        optimalPh = 6.5;
        contaminantName = 'Arsénico (As)';
        break;
      case ContaminantType.heavyMetals:
        baseK = 0.028;
        maxEfficiency = 89.0;
        optimalPh = 7.0;
        contaminantName = 'Metales Pesados';
        break;
      case ContaminantType.fieldSample:
        baseK = 0.022;
        maxEfficiency = 84.0;
        optimalPh = 7.2;
        contaminantName = 'Muestra de Campo (Endhó/Tula)';
        break;
    }

    // 2. Factores de rendimiento (dosis y pH)
    // Factor dosis: satura con la masa de biochar
    final doseFactor = (input.biocharDose / (input.biocharDose + 1.5)).clamp(
      0.1,
      1.0,
    );

    // Factor pH: penalización gaussiana conforme se aleja del pH óptimo
    final phDelta = input.ph - optimalPh;
    final phFactor = exp(-0.15 * phDelta * phDelta).clamp(0.3, 1.0);

    final baseCapacity = maxEfficiency * doseFactor * phFactor;

    // 3. Corridas estocásticas (Monte Carlo)
    final numRuns = input.numRuns.clamp(10, 5000);
    List<List<double>> allRunsConcentrations = [];
    List<double> finalEfficiencies = [];
    List<double> finalConcentrations = [];

    for (int run = 0; run < numRuns; run++) {
      List<double> runConc = [];
      // Ruido gaussiano por corrida
      final noise = _gaussianNoise(mean: 0, stdDev: 3.0);
      double runCapacity = (baseCapacity + noise).clamp(5.0, 98.5);

      for (double t = 0; t <= 120; t += 10) {
        double removalFraction = (runCapacity / 100.0) * (t / (20.0 + t * 0.8));
        double c = input.initialConcentration * (1.0 - removalFraction);
        c +=
            (randomNoiseFactor() - 0.5) *
            0.05 *
            c; // ruido menor por punto de tiempo
        runConc.add(c < 0 ? 0 : c);
      }
      allRunsConcentrations.add(runConc);

      double finalC = runConc.last;
      double eff =
          ((input.initialConcentration - finalC) / input.initialConcentration) *
          100;
      finalEfficiencies.add(eff.clamp(0, 100));
      finalConcentrations.add(finalC);
    }

    // 4. Promedios y desviación estándar
    double avgEfficiency =
        finalEfficiencies.reduce((a, b) => a + b) / finalEfficiencies.length;
    double avgFinalConc =
        finalConcentrations.reduce((a, b) => a + b) /
        finalConcentrations.length;

    double variance =
        finalEfficiencies
            .map((e) => pow(e - avgEfficiency, 2))
            .reduce((a, b) => a + b) /
        finalEfficiencies.length;
    double stdDev = sqrt(variance);

    // 5. Curva cinética con bandas de confianza (10% - 90%)
    List<TimePoint> kineticCurve = [];
    List<double> timeSteps = [
      0,
      10,
      20,
      30,
      40,
      50,
      60,
      70,
      80,
      90,
      100,
      110,
      120,
    ];

    for (int i = 0; i < timeSteps.length; i++) {
      List<double> valuesAtT = allRunsConcentrations
          .map((run) => run[i])
          .toList();
      valuesAtT.sort();
      double mean = valuesAtT.reduce((a, b) => a + b) / valuesAtT.length;
      double lower = valuesAtT[(valuesAtT.length * 0.10).floor()];
      double upperBound = valuesAtT[(valuesAtT.length * 0.90).floor()];

      kineticCurve.add(
        TimePoint(
          time: timeSteps[i],
          meanConcentration: mean,
          lowerBound: lower,
          upperBound: upperBound,
        ),
      );
    }

    // 6. Indicadores secundarios
    double magneticRecovery = (93.0 + (input.biocharDose * 0.4)).clamp(
      82.0,
      98.5,
    );
    double reusability = (avgEfficiency * 0.88).clamp(45.0, 95.0);

    // 7. Comparación por metales
    List<MetalComparison> metalComparisons = [];
    if (input.contaminantType == ContaminantType.heavyMetals) {
      Map<String, double> metals = {
        'Pb': 5.2,
        'Cd': 3.1,
        'Cu': 7.4,
        'Cr VI': 4.8,
        'Zn': 8.0,
      };
      metals.forEach((name, c0) {
        metalComparisons.add(
          MetalComparison(
            metalName: name,
            initialConc: c0,
            finalConc: (c0 * (1.0 - (avgEfficiency / 100.0))).clamp(0.01, c0),
          ),
        );
      });
    } else {
      metalComparisons.add(
        MetalComparison(
          metalName: contaminantName,
          initialConc: input.initialConcentration,
          finalConc: avgFinalConc,
        ),
      );
    }

    // 8. Construcción del Diagnóstico Dinámico
    String diagnosticMessage = _buildDiagnostico(
      input: input,
      avgEfficiency: avgEfficiency,
      stdDev: stdDev,
      avgFinalConc: avgFinalConc,
      magneticRecovery: magneticRecovery,
      reusability: reusability,
      maxEfficiency: maxEfficiency,
      optimalPh: optimalPh,
      doseFactor: doseFactor,
      phFactor: phFactor,
      contaminantName: contaminantName,
    );

    return SimulationOutput(
      averageRemovalEfficiency: avgEfficiency,
      averageFinalConcentration: avgFinalConc,
      magneticRecovery: magneticRecovery,
      reusabilityEfficiency3Cycles: reusability,
      kineticCurve: kineticCurve,
      metalComparisons: metalComparisons,
      diagnosticMessage: diagnosticMessage,
    );
  }

  /// Construye un diagnóstico dinámico combinando eficiencia,
  /// confiabilidad estadística, factor limitante y reutilización.
  static String _buildDiagnostico({
    required SimulationInput input,
    required double avgEfficiency,
    required double stdDev,
    required double avgFinalConc,
    required double magneticRecovery,
    required double reusability,
    required double maxEfficiency,
    required double optimalPh,
    required double doseFactor,
    required double phFactor,
    required String contaminantName,
  }) {
    final partes = <String>[];

    // --- 1) Nivel de eficiencia y lectura práctica ---
    if (avgEfficiency >= 88) {
      partes.add(
        '• Nivel de Operación: Excelente (${avgEfficiency.toStringAsFixed(1)}%). '
        'El sistema trabaja muy cerca del techo de remoción teórico para $contaminantName '
        '(${maxEfficiency.toStringAsFixed(0)}%). Estas condiciones son idóneas para pruebas a escala piloto o planta.',
      );
    } else if (avgEfficiency >= 70) {
      partes.add(
        '• Nivel de Operación: Bueno (${avgEfficiency.toStringAsFixed(1)}%). '
        'El proceso remueve la mayor parte de $contaminantName, pero existe margen de mejora '
        'antes de alcanzar el máximo posible (${maxEfficiency.toStringAsFixed(0)}%).',
      );
    } else if (avgEfficiency >= 45) {
      partes.add(
        '• Nivel de Operación: Moderado / Subóptimo (${avgEfficiency.toStringAsFixed(1)}%). '
        'La remoción es parcial y deja ${avgFinalConc.toStringAsFixed(2)} mg/L de residuo. '
        'No se aconseja escalar sin antes optimizar los parámetros.',
      );
    } else {
      partes.add(
        '• Nivel de Operación: Bajo Ineficiente (${avgEfficiency.toStringAsFixed(1)}%). '
        'Bajo la configuración actual, el biochar no retiene suficiente $contaminantName. '
        'Se requiere replantear la dosis o el pH de la mezcla.',
      );
    }

    // --- 2) Confiabilidad estadística (Monte Carlo) ---
    final cv = avgEfficiency > 0 ? (stdDev / avgEfficiency) * 100 : 0.0;
    if (cv < 6) {
      partes.add(
        '• Confiabilidad Estadística: Alta (CV ≈ ${cv.toStringAsFixed(1)}%). '
        'La dispersión entre las ${input.numRuns} corridas fue mínima, confirmando que la respuesta del lecho es altamente reproducible.',
      );
    } else if (cv < 15) {
      partes.add(
        '• Confiabilidad Estadística: Moderada (CV ≈ ${cv.toStringAsFixed(1)}%). '
        'Existe variabilidad leve entre corridas estocásticas. Es un resultado útil pero conviene considerar la banda de incertidumbre.',
      );
    } else {
      partes.add(
        '• Confiabilidad Estadística: Baja (CV ≈ ${cv.toStringAsFixed(1)}%). '
        'Se detectó alta variabilidad entre simulaciones. Se recomienda aumentar el número de corridas Monte Carlo o controlar mejor el pH en operación.',
      );
    }

    // --- 3) Factor limitante y recomendación operacional ---
    if (avgEfficiency < 88) {
      if (phFactor < doseFactor - 0.08) {
        final direccion = input.ph < optimalPh ? 'incrementar' : 'disminuir';
        partes.add(
          '• Recomendación Operativa: Ajustar pH. El pH actual (${input.ph.toStringAsFixed(1)}) '
          'se aleja del valor óptimo (${optimalPh.toStringAsFixed(1)}). Se sugiere $direccion el pH '
          'hacia ${optimalPh.toStringAsFixed(1)} antes de añadir más masa de biochar.',
        );
      } else if (doseFactor < phFactor - 0.08) {
        final dosisSugerida = (input.biocharDose * 1.5).clamp(
          input.biocharDose + 0.5,
          10.0,
        );
        partes.add(
          '• Recomendación Operativa: Incrementar Dosis. La masa actual (${input.biocharDose.toStringAsFixed(1)} g/L) '
          'no satura los sitios de adsorción. Probar con una dosis cercana a ${dosisSugerida.toStringAsFixed(1)} g/L.',
        );
      } else {
        partes.add(
          '• Recomendación Operativa: Dosis y pH guardan equilibrio. Para ganar más eficiencia se requiere '
          'extender el tiempo de residencia o recurrir a un biochar con mayor grado de activación superficial.',
        );
      }
    }

    // --- 4) Recuperación magnética y reutilización ---
    if (magneticRecovery >= 90 && reusability >= 70) {
      partes.add(
        '• Reutilización y Viabilidad: Excelente. La separación magnética alcanza un ${magneticRecovery.toStringAsFixed(1)}% '
        'y se retiene el ${reusability.toStringAsFixed(1)}% de la capacidad tras 3 ciclos, reduciendo los costos operativos de insumo.',
      );
    } else {
      partes.add(
        '• Reutilización y Viabilidad: Limitada. La eficiencia conservada tras 3 ciclos (${reusability.toStringAsFixed(1)}%) '
        'sugiere programar regeneración química periódica del material.',
      );
    }

    return partes.join('\n\n');
  }

  static double _gaussianNoise({required double mean, required double stdDev}) {
    final u1 = 1.0 - _rng.nextDouble();
    final u2 = _rng.nextDouble();
    final z0 = sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
    return mean + z0 * stdDev;
  }

  static double randomNoiseFactor() {
    return _rng.nextDouble();
  }
}
