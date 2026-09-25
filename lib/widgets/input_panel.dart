import 'package:flutter/material.dart';
import '../models/simulation_models.dart';
import '../theme/app_theme.dart';

class InputPanel extends StatefulWidget {
  final SimulationInput input;
  final ValueChanged<SimulationInput> onChanged;
  final VoidCallback onRun;
  final bool isRunning;

  const InputPanel({
    super.key,
    required this.input,
    required this.onChanged,
    required this.onRun,
    required this.isRunning,
  });

  @override
  State<InputPanel> createState() => _InputPanelState();
}

class _InputPanelState extends State<InputPanel> {
  late final TextEditingController _c0Controller;
  late final TextEditingController _corridasController;

  @override
  void initState() {
    super.initState();
    _c0Controller = TextEditingController(
      text: widget.input.initialConcentration.toStringAsFixed(1),
    );
    _corridasController = TextEditingController(
      text: widget.input.numRuns.toString(),
    );
  }

  @override
  void dispose() {
    _c0Controller.dispose();
    _corridasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Entradas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          const _SectionLabel('Contaminante Principal / Matriz de Agua'),
          const SizedBox(height: 8),
          _ContaminantSelector(
            selected: input.contaminantType,
            onSelected: (type) {
              setState(() {
                widget.input.contaminantType = type;
              });
              widget.onChanged(widget.input);
            },
          ),

          const SizedBox(height: 24),
          const _SectionLabel('Parámetros del experimento y Biochar Magnético'),
          const SizedBox(height: 12),

          _SliderField(
            label: 'Dosis de Biochar Magnético',
            value: input.biocharDose,
            min: 0.1,
            max: 10,
            unit: 'g/L',
            onChanged: (v) {
              setState(() {
                widget.input.biocharDose = v;
              });
              widget.onChanged(widget.input);
            },
          ),
          _SliderField(
            label: 'pH de la Solución',
            value: input.ph,
            min: 3,
            max: 10,
            unit: '',
            divisions: 70,
            subtitle: 'Parámetro crítico mencionado en el estudio',
            onChanged: (v) {
              setState(() {
                widget.input.ph = v;
              });
              widget.onChanged(widget.input);
            },
          ),
          _SliderField(
            label: 'Tiempo de Contacto',
            value: input.contactTime,
            min: 5,
            max: 120,
            unit: 'min',
            subtitle: 'Equilibrio esperado ≈ 60 min',
            onChanged: (v) {
              setState(() {
                widget.input.contactTime = v;
              });
              widget.onChanged(widget.input);
            },
          ),

          const SizedBox(height: 16),
          const _SectionLabel('Concentración Inicial (C₀)'),
          const SizedBox(height: 8),
          TextField(
            controller: _c0Controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: 'mg/L',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed != null && parsed > 0) {
                widget.input.initialConcentration = parsed;
                widget.onChanged(widget.input);
              }
            },
          ),

          const SizedBox(height: 24),
          const _SectionLabel('Configuración de la Simulación'),
          const SizedBox(height: 8),
          TextField(
            controller: _corridasController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Número de Corridas',
              helperText: 'Corridas estocásticas tipo Monte Carlo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed >= 10) {
                widget.input.numRuns = parsed;
                widget.onChanged(widget.input);
              }
            },
          ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.isRunning ? null : widget.onRun,
              icon: widget.isRunning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.science_outlined),
              label: Text(
                widget.isRunning
                    ? 'Ejecutando...'
                    : 'Ejecutar Simulación de ${input.numRuns} Corridas',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.primary,
      ),
    );
  }
}

class _ContaminantSelector extends StatelessWidget {
  final ContaminantType selected;
  final ValueChanged<ContaminantType> onSelected;

  const _ContaminantSelector({
    required this.selected,
    required this.onSelected,
  });

  String _getLabel(ContaminantType type) {
    switch (type) {
      case ContaminantType.arsenic:
        return 'Arsénico (As)';
      case ContaminantType.heavyMetals:
        return 'Metales Pesados';
      case ContaminantType.fieldSample:
        return 'Muestra de Campo (Presa Endhó / Río Tula)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ContaminantType>(
          value: selected,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          borderRadius: BorderRadius.circular(12),
          items: ContaminantType.values
              .map((c) => DropdownMenuItem(value: c, child: Text(_getLabel(c))))
              .toList(),
          onChanged: (c) {
            if (c != null) onSelected(c);
          },
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final String? subtitle;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.subtitle,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${value.toStringAsFixed(1)} $unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions ?? (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
