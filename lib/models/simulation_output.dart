/// Punto de la curva cinética promedio con su banda de dispersión
/// (percentiles 10-90 sobre las N corridas estocásticas).
class KineticPoint {
  final double tiempoMin;
  final double concentracionPromedio;
  final double bandaBaja;
  final double bandaAlta;

  const KineticPoint({
    required this.tiempoMin,
    required this.concentracionPromedio,
    required this.bandaBaja,
    required this.bandaAlta,
  });
}

/// Resultado completo de correr las N simulaciones estocásticas.
class SimulationOutput {
  final double eficienciaPromedio; // %
  final double eficienciaDesviacion; // % (desviación estándar entre corridas)
  final double concentracionFinalPromedio; // mg/L
  final double recuperacionMagnetica; // %
  final double conservacionReutilizacion; // % tras 3 ciclos
  final List<KineticPoint> curvaCinetica;
  final double c0;
  final double cfPorMetal; // usado solo si aplica comparación individual
  final String diagnostico;

  const SimulationOutput({
    required this.eficienciaPromedio,
    required this.eficienciaDesviacion,
    required this.concentracionFinalPromedio,
    required this.recuperacionMagnetica,
    required this.conservacionReutilizacion,
    required this.curvaCinetica,
    required this.c0,
    required this.cfPorMetal,
    required this.diagnostico,
  });
}
