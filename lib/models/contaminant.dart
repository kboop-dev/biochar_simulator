/// Representa un contaminante o matriz de agua seleccionable en el
/// Panel de Entradas, según el documento de referencia del proyecto.
class Contaminant {
  final String id;
  final String label;
  final String unit;
  final ContaminantCategory category;

  /// Eficiencia base de remoción (0-1) en condiciones "ideales"
  /// (pH óptimo, dosis suficiente, tiempo de contacto en equilibrio).
  /// Sirve como techo realista para cada especie, basado en el orden
  /// de afinidad típico del biochar magnético reportado en literatura:
  /// Pb, Cr(VI) y As suelen tener mayor afinidad que Zn o Cu.
  final double maxEfficiency;

  /// pH óptimo aproximado de remoción para este contaminante.
  final double optimalPh;

  /// Qué tan sensible es el contaminante a alejarse del pH óptimo
  /// (menor = más tolerante, mayor = más sensible).
  final double phSensitivity;

  /// Valor guía orientativo de calidad de agua (mg/L), usado solo como
  /// referencia para el diagnóstico automático (p. ej. valores guía de la
  /// OMS para agua de consumo). Es un dato de referencia general, no
  /// sustituye la normativa específica aplicable a cada caso de uso.
  /// Null cuando no aplica una comparación directa de este tipo.
  final double? referenceLimitMgL;
  final String? referenceLimitLabel;

  const Contaminant({
    required this.id,
    required this.label,
    required this.unit,
    required this.category,
    required this.maxEfficiency,
    required this.optimalPh,
    required this.phSensitivity,
    this.referenceLimitMgL,
    this.referenceLimitLabel,
  });
}

enum ContaminantCategory { modelo, metalPesado, muestraCampo }

/// Catálogo fijo que reproduce el "Selector de Contaminante Principal /
/// Matriz de Agua" descrito en el documento.
const List<Contaminant> kContaminants = [
  Contaminant(
    id: 'arsenico',
    label: 'Arsénico (As) — Contaminante modelo',
    unit: 'mg/L',
    category: ContaminantCategory.modelo,
    maxEfficiency: 0.96,
    optimalPh: 6.5,
    phSensitivity: 0.045,
    referenceLimitMgL: 0.01,
    referenceLimitLabel: 'valor guía OMS agua de consumo',
  ),
  Contaminant(
    id: 'plomo',
    label: 'Plomo (Pb)',
    unit: 'mg/L',
    category: ContaminantCategory.metalPesado,
    maxEfficiency: 0.97,
    optimalPh: 6.0,
    phSensitivity: 0.035,
    referenceLimitMgL: 0.01,
    referenceLimitLabel: 'valor guía OMS agua de consumo',
  ),
  Contaminant(
    id: 'cadmio',
    label: 'Cadmio (Cd)',
    unit: 'mg/L',
    category: ContaminantCategory.metalPesado,
    maxEfficiency: 0.9,
    optimalPh: 7.0,
    phSensitivity: 0.04,
    referenceLimitMgL: 0.003,
    referenceLimitLabel: 'valor guía OMS agua de consumo',
  ),
  Contaminant(
    id: 'cobre',
    label: 'Cobre (Cu)',
    unit: 'mg/L',
    category: ContaminantCategory.metalPesado,
    maxEfficiency: 0.88,
    optimalPh: 6.5,
    phSensitivity: 0.04,
    referenceLimitMgL: 2.0,
    referenceLimitLabel: 'valor guía OMS agua de consumo',
  ),
  Contaminant(
    id: 'cromo_hex',
    label: 'Cromo Hexavalente (Cr VI)',
    unit: 'mg/L',
    category: ContaminantCategory.metalPesado,
    maxEfficiency: 0.93,
    optimalPh: 4.5,
    phSensitivity: 0.05,
    referenceLimitMgL: 0.05,
    referenceLimitLabel: 'valor guía OMS para cromo total',
  ),
  Contaminant(
    id: 'zinc',
    label: 'Zinc (Zn)',
    unit: 'mg/L',
    category: ContaminantCategory.metalPesado,
    maxEfficiency: 0.85,
    optimalPh: 7.0,
    phSensitivity: 0.038,
  ),
  Contaminant(
    id: 'muestra_campo',
    label: 'Muestra de Campo — Presa Endhó / Río Tula (DBO)',
    unit: 'mg/L DBO',
    category: ContaminantCategory.muestraCampo,
    maxEfficiency: 0.75,
    optimalPh: 7.0,
    phSensitivity: 0.03,
  ),
];
