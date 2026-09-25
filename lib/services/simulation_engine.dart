import 'dart:math';
import '../models/simulation_models.dart';

class SimulationEngine {
  static SimulationOutput run(SimulationInput input) {
    final random = Random();

    double baseK = 0.03;
    double maxRemoval = 92.0;

    switch (input.contaminantType) {
      case ContaminantType.arsenic:
        baseK = 0.035;
        maxRemoval = 95.0;
        break;
      case ContaminantType.heavyMetals:
        baseK = 0.028;
        maxRemoval = 89.0;
        break;
      case ContaminantType.fieldSample: // Presa Endhó / Río Tula
        baseK = 0.022;
        maxRemoval = 84.0;
        break;
    }

    // Efecto del pH (óptimo entre 6.0 y 8.0)
    double phFactor = 1.0 - (input.ph - 7.0).abs() * 0.08;
    phFactor = phFactor.clamp(0.5, 1.1);

    // Efecto de la dosis de biochar
    double doseFactor = (input.biocharDose / (input.biocharDose + 1.5));

    List<List<double>> allRunsConcentrations = [];
    List<double> finalEfficiencies = [];
    List<double> finalConcentrations = [];

    for (int run = 0; run < input.numRuns; run++) {
      List<double> runConc = [];
      double runCapacityNoise =
          maxRemoval *
          phFactor *
          doseFactor *
          (1.0 + (random.nextDouble() - 0.5) * 0.08);
      runCapacityNoise = runCapacityNoise.clamp(10.0, 98.0);

      for (double t = 0; t <= 120; t += 10) {
        double removalFraction =
            (runCapacityNoise / 100.0) * (t / (20.0 + t * 0.8));
        double c = input.initialConcentration * (1.0 - removalFraction);
        c += (random.nextDouble() - 0.5) * 0.2 * (c > 0 ? c : 0);
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

    double avgEfficiency =
        finalEfficiencies.reduce((a, b) => a + b) / finalEfficiencies.length;
    double avgFinalConc =
        finalConcentrations.reduce((a, b) => a + b) /
        finalConcentrations.length;

    double magneticRecovery = (93.0 + (input.biocharDose * 0.5)).clamp(
      85.0,
      98.5,
    );
    double reusability = (avgEfficiency * 0.88).clamp(50.0, 95.0);

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
          metalName: input.contaminantType == ContaminantType.arsenic
              ? 'Arsénico (As)'
              : 'Muestra Endhó / Tula',
          initialConc: input.initialConcentration,
          finalConc: avgFinalConc,
        ),
      );
    }

    String diagnostic = '';
    if (avgEfficiency > 90) {
      diagnostic =
          'Excelente rendimiento. Las condiciones de pH (${input.ph}) y dosis (${input.biocharDose} g/L) maximizan la adsorción activa.';
    } else if (avgEfficiency > 75) {
      diagnostic =
          'Buen desempeño de filtración. Se observa estabilización cerca del minuto 60. Considere ajustar el pH hacia la neutralidad para mejorar la eficiencia.';
    } else {
      diagnostic =
          'Eficiencia moderada. El pH actual o la dosis de biochar limitan los sitios activos de adsorción. Se recomienda incrementar la dosis o ajustar el pH.';
    }

    return SimulationOutput(
      averageRemovalEfficiency: avgEfficiency,
      averageFinalConcentration: avgFinalConc,
      magneticRecovery: magneticRecovery,
      reusabilityEfficiency3Cycles: reusability,
      kineticCurve: kineticCurve,
      metalComparisons: metalComparisons,
      diagnosticMessage: diagnostic,
    );
  }
}
