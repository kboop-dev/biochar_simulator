import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biochar_simulator/main.dart';

void main() {
  testWidgets('La app carga y muestra el título principal', (tester) async {
    await tester.pumpWidget(const BiocharSimulatorApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Simulador de filtración BIOCHAR'), findsWidgets);
    expect(find.text('Panel de Entradas'), findsOneWidget);
  });
}
