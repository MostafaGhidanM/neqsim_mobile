import 'package:flutter/material.dart';

import '../models/fluid_input.dart';
import '../models/pipe_layer.dart';
import '../models/pipeline_point.dart';
import '../models/saved_fluid.dart';
import '../services/saved_fluids_service.dart';
import 'chat_screen.dart';
import 'run_screen.dart';

class FluidScreen extends StatefulWidget {
  final List<PipelinePoint> points;
  final bool isEngineering;
  final List<PipeLayer>? pipeLayers;
  final String? environment;

  const FluidScreen({
    super.key,
    required this.points,
    required this.isEngineering,
    this.pipeLayers,
    this.environment,
  });

  @override
  State<FluidScreen> createState() => _FluidScreenState();
}

class _FluidScreenState extends State<FluidScreen> {
  final _formKey = GlobalKey<FormState>();
  List<SavedFluid> _savedFluids = [];
  SavedFluid? _selectedFluid;
  double _temperatureC = 15;
  double _ambientTemperatureC = 10;
  double _pressureBara = 10;
  bool _solveForStartingPressure = true; // true = give arrival, get starting; false = give starting, get arrival
  double _flowRate = 5;
  String _flowUnit = 'mmscfd';
  double _diameterM = 0.3;
  double _roughnessM = 50.0e-6;

  static const faFlowUnits = ['mmscfd', 'bbls/day', 'MSm3/day', 'kg/hr', 'Sm3/day'];

  @override
  void initState() {
    super.initState();
    _loadSavedFluids();
  }

  Future<void> _loadSavedFluids() async {
    final list = await SavedFluidsService.getSavedFluids();
    if (mounted) setState(() {
      _savedFluids = list;
      if (_selectedFluid == null && list.isNotEmpty) {
        _selectedFluid = list.first;
      }
    });
  }

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
            const Text('Saved fluid', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<SavedFluid?>(
              value: _selectedFluid,
              decoration: const InputDecoration(
                labelText: 'Select fluid',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<SavedFluid?>(value: null, child: Text('— Select —')),
                ..._savedFluids.map((f) => DropdownMenuItem<SavedFluid?>(
                  value: f,
                  child: Text(f.name),
                )),
              ],
              onChanged: (v) => setState(() => _selectedFluid = v),
            ),
            if (_savedFluids.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Define and save a fluid first (Define Fluid screen).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 12),
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
              initialValue: _ambientTemperatureC.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Ambient temperature (°C)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _ambientTemperatureC = double.tryParse(v) ?? _ambientTemperatureC,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool>(
              value: _solveForStartingPressure,
              decoration: const InputDecoration(
                labelText: 'Solve for',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: true, child: Text('Starting pressure (given arrival)')),
                DropdownMenuItem(value: false, child: Text('Arrival pressure (given starting)')),
              ],
              onChanged: (v) => setState(() => _solveForStartingPressure = v ?? true),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _pressureBara.toString(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _solveForStartingPressure ? 'Arrival pressure (bara)' : 'Starting pressure (bara)',
                border: const OutlineInputBorder(),
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
                    items: faFlowUnits
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _flowUnit = v ?? _flowUnit),
                  ),
                ),
              ],
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
                onPressed: (_savedFluids.isEmpty && widget.isEngineering)
                    ? null
                    : () {
                        final fluid = FluidInput(
                          temperatureC: _temperatureC,
                          pressureBara: _solveForStartingPressure ? _pressureBara : 0,
                          flowRate: _flowRate,
                          flowUnit: _flowUnit,
                          fluidType: _selectedFluid?.type ?? 'compositional',
                          preset: _selectedFluid?.type == 'black_oil' ? 'black oil' : 'dry gas',
                          diameterM: _diameterM,
                          roughnessM: _roughnessM,
                          savedFluid: _selectedFluid,
                          startingPressureBara: _solveForStartingPressure ? null : _pressureBara,
                          ambientTemperatureC: _ambientTemperatureC,
                          pipeLayers: widget.pipeLayers,
                          environment: widget.environment,
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
