enum ContaminantType { arsenic, heavyMetals, fieldSample }

class SimulationInput {
  ContaminantType contaminantType;
  double biocharDose; // g/L
  double ph; // 3 - 10
  double contactTime; // min
  double initialConcentration; // mg/L
  int numRuns; // por defecto 500

  SimulationInput({
    this.contaminantType = ContaminantType.arsenic,
    this.biocharDose = 2.0,
    this.ph = 7.0,
    this.contactTime = 60.0,
    this.initialConcentration = 10.0,
    this.numRuns = 500,
  });

  // Constructor factory requerido por HomeScreen
  factory SimulationInput.initial() {
    return SimulationInput();
  }
}

class SimulationOutput {
  final double averageRemovalEfficiency; // %
  final double averageFinalConcentration; // mg/L
  final double magneticRecovery; // %
  final double reusabilityEfficiency3Cycles; // %
  final List<TimePoint> kineticCurve;
  final List<MetalComparison> metalComparisons;
  final String diagnosticMessage;

  SimulationOutput({
    required this.averageRemovalEfficiency,
    required this.averageFinalConcentration,
    required this.magneticRecovery,
    required this.reusabilityEfficiency3Cycles,
    required this.kineticCurve,
    required this.metalComparisons,
    required this.diagnosticMessage,
  });
}

class TimePoint {
  final double time;
  final double meanConcentration;
  final double lowerBound;
  final double upperBound;

  TimePoint({
    required this.time,
    required this.meanConcentration,
    required this.lowerBound,
    required this.upperBound,
  });
}

class MetalComparison {
  final String metalName;
  final double initialConc;
  final double finalConc;

  MetalComparison({
    required this.metalName,
    required this.initialConc,
    required this.finalConc,
  });
}
