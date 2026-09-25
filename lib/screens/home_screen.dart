import 'package:flutter/material.dart';
import '../models/simulation_models.dart';
import '../services/simulation_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/comparison_chart.dart';
import '../widgets/diagnostic_panel.dart';
import '../widgets/input_panel.dart';
import '../widgets/kinetics_chart.dart';
import '../widgets/kpi_cards.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SimulationInput _input = SimulationInput.initial();
  SimulationOutput? _output;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  Future<void> _runSimulation() async {
    if (_isRunning) return; // Evita ejecuciones superpuestas

    setState(() => _isRunning = true);

    // Permite que Flutter pinte el indicador de carga en el UI antes de hacer los cálculos
    await Future.delayed(const Duration(milliseconds: 120));

    final result = SimulationEngine.run(_input);

    if (!mounted) return;

    setState(() {
      _output = result;
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de filtración BIOCHAR 🧪')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;

          final inputPanelContent = InputPanel(
            input: _input,
            isRunning: _isRunning,
            onChanged: (v) {
              setState(() => _input = v);
            },
            onRun: _runSimulation,
          );

          final resultsContent = _output == null || _isRunning
              ? const SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Ejecutando corridas estocásticas Monte Carlo...'),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel de Resultados / Dashboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      KpiCards(output: _output!, unit: 'mg/L'),
                      const SizedBox(height: 20),
                      KineticsChart(output: _output!),
                      const SizedBox(height: 20),
                      ComparisonChart(input: _input, output: _output!),
                      const SizedBox(height: 20),
                      DiagnosticPanel(output: _output!),
                    ],
                  ),
                );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: SingleChildScrollView(child: resultsContent)),
                Container(
                  width: 380,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(left: BorderSide(color: AppColors.border)),
                  ),
                  child: SingleChildScrollView(child: inputPanelContent),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: inputPanelContent,
                ),
                resultsContent,
              ],
            ),
          );
        },
      ),
    );
  }
}
