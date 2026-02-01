import 'package:flutter/material.dart';

import '../models/fluid_input.dart';
import '../models/pipeline_point.dart';
import 'chat_screen.dart';
import 'run_screen.dart';

class FluidScreen extends StatefulWidget {
  final List<PipelinePoint> points;
  final bool isEngineering;

  const FluidScreen({
    super.key,
    required this.points,
    required this.isEngineering,
  });

  @override
  State<FluidScreen> createState() => _FluidScreenState();
}

class _FluidScreenState extends State<FluidScreen> {
  final _formKey = GlobalKey<FormState>();
  double _temperatureC = 15;
  double _pressureBara = 10;
  double _flowRate = 5;
  String _flowUnit = 'MSm3/day';
  String _fluidType = 'compositional';
  String? _preset = 'dry gas';
  double _diameterM = 0.3;
  double _roughnessM = 50.0e-6;

  static const blackOilPresets = ['black oil', 'light oil'];
  static const compositionalPresets = ['dry gas', 'rich gas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluid & conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _temperatureC.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Temperature (°C)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _temperatureC = double.tryParse(v) ?? _temperatureC,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _pressureBara.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Arrival pressure (bara)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _pressureBara = double.tryParse(v) ?? _pressureBara,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: _flowRate.toString(),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Flow rate',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _flowRate = double.tryParse(v) ?? _flowRate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _flowUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: ['MSm3/day', 'kg/hr', 'Sm3/day']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _flowUnit = v ?? _flowUnit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _fluidType,
              decoration: const InputDecoration(
                labelText: 'Fluid type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'black_oil', child: Text('Black oil')),
                DropdownMenuItem(value: 'compositional', child: Text('Compositional')),
              ],
              onChanged: (v) {
                setState(() {
                  _fluidType = v ?? _fluidType;
                  _preset = _fluidType == 'black_oil' ? 'black oil' : 'dry gas';
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _preset,
              decoration: InputDecoration(
                labelText: _fluidType == 'black_oil' ? 'Preset (black oil)' : 'Preset (gas)',
                border: const OutlineInputBorder(),
              ),
              items: (_fluidType == 'black_oil' ? blackOilPresets : compositionalPresets)
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _preset = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _diameterM.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Pipe diameter (m)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _diameterM = double.tryParse(v) ?? _diameterM,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _roughnessM.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Pipe roughness (m)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _roughnessM = double.tryParse(v) ?? _roughnessM,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final fluid = FluidInput(
                    temperatureC: _temperatureC,
                    pressureBara: _pressureBara,
                    flowRate: _flowRate,
                    flowUnit: _flowUnit,
                    fluidType: _fluidType,
                    preset: _preset,
                    diameterM: _diameterM,
                    roughnessM: _roughnessM,
                  );
                  if (widget.isEngineering) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RunScreen(
                          points: widget.points,
                          fluid: fluid,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          points: widget.points,
                          fluid: fluid,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
