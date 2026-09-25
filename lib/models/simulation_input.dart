import 'contaminant.dart';

/// Parámetros capturados en el Panel de Entradas.
class SimulationInput {
  final Contaminant contaminant;
  final double dosisBiocharGL; // g/L — dosis de biochar magnético
  final double ph; // 3 a 10
  final double tiempoContactoMin; // minutos, equilibrio ~60 min
  final double c0; // mg/L — concentración inicial
  final int numeroCorridas; // corridas estocásticas Monte Carlo

  const SimulationInput({
    required this.contaminant,
    required this.dosisBiocharGL,
    required this.ph,
    required this.tiempoContactoMin,
    required this.c0,
    required this.numeroCorridas,
  });

  SimulationInput copyWith({
    Contaminant? contaminant,
    double? dosisBiocharGL,
    double? ph,
    double? tiempoContactoMin,
    double? c0,
    int? numeroCorridas,
  }) {
    return SimulationInput(
      contaminant: contaminant ?? this.contaminant,
      dosisBiocharGL: dosisBiocharGL ?? this.dosisBiocharGL,
      ph: ph ?? this.ph,
      tiempoContactoMin: tiempoContactoMin ?? this.tiempoContactoMin,
      c0: c0 ?? this.c0,
      numeroCorridas: numeroCorridas ?? this.numeroCorridas,
    );
  }

  static SimulationInput initial() => SimulationInput(
        contaminant: kContaminants.first,
        dosisBiocharGL: 2.0,
        ph: 6.5,
        tiempoContactoMin: 60,
        c0: 10.0,
        numeroCorridas: 500,
      );
}
