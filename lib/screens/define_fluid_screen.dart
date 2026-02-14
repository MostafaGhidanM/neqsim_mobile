import 'package:flutter/material.dart';

import '../models/saved_fluid.dart';
import '../services/fluid_definition_api_service.dart';
import '../services/saved_fluids_service.dart';
import '../widgets/phase_envelope_chart.dart';

class DefineFluidScreen extends StatefulWidget {
  const DefineFluidScreen({super.key});

  @override
  State<DefineFluidScreen> createState() => _DefineFluidScreenState();
}

class _DefineFluidScreenState extends State<DefineFluidScreen> {
  final _nameController = TextEditingController(text: '');
  bool _isCompositional = true;
  List<String> _componentNames = [];
  final List<Map<String, dynamic>> _compositionalRows = [
    {'name': 'methane', 'mole_fraction': 0.9},
    {'name': 'ethane', 'mole_fraction': 0.1},
  ];
  double _gorSm3Sm3 = 100.0;
  double _waterCutPercent = 10.0;  // 10%, 70%, etc.
  double? _apiGravity;  // e.g. 21 for 21°API
  bool _loading = false;
  String? _error;
  PhaseEnvelopeData? _envelopeData;
  String? _modelNote;
  String? _eosUsed;

  @override
  void initState() {
    super.initState();
    _loadComponentNames();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveFluid() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a name for the fluid')),
        );
      }
      return;
    }
    SavedFluid? fluid;
    if (_isCompositional) {
      final sum = _sumMoleFractions();
      if (sum <= 0 || (sum - 1.0).abs() > 0.01) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fix compositional mole fractions (sum = 1.0)')),
          );
        }
        return;
      }
      final components = _compositionalRows
          .map((r) => {
                'name': r['name'] as String,
                'mole_fraction': (r['mole_fraction'] as num).toDouble(),
              })
          .toList();
      fluid = SavedFluid(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: 'compositional',
        compositional: CompositionalDefinition(components: components),
      );
    } else {
      fluid = SavedFluid(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: 'black_oil',
        blackOil: BlackOilDefinition(
          gorSm3Sm3: _gorSm3Sm3,
          waterCutFraction: _waterCutPercent / 100.0,
          apiGravity: _apiGravity,
        ),
      );
    }
    await SavedFluidsService.saveFluid(fluid);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "$name" to device storage. It will be available after every app restart.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadComponentNames() async {
    final names = await FluidDefinitionApiService.getComponentNames();
    if (mounted) setState(() => _componentNames = names);
  }

  double _sumMoleFractions() {
    double sum = 0;
    for (final row in _compositionalRows) {
      sum += (row['mole_fraction'] as num?)?.toDouble() ?? 0;
    }
    return sum;
  }

  void _addCompositionalRow() {
    setState(() {
      _compositionalRows.add({
        'name': _componentNames.isNotEmpty ? _componentNames.first : 'methane',
        'mole_fraction': 0.0,
      });
    });
  }

  void _removeCompositionalRow(int index) {
    if (_compositionalRows.length <= 1) return;
    setState(() => _compositionalRows.removeAt(index));
  }

  Future<void> _calculateCompositional() async {
    final sum = _sumMoleFractions();
    if (sum <= 0) {
      setState(() {
        _error = 'Enter at least one component with positive mole fraction';
        _envelopeData = null;
      });
      return;
    }
    if ((sum - 1.0).abs() > 0.01) {
      setState(() {
        _error = 'Mole fractions should sum to 1.0 (current: ${sum.toStringAsFixed(3)})';
        _envelopeData = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _envelopeData = null;
      _modelNote = null;
      _eosUsed = null;
    });

    final components = _compositionalRows
        .map((r) => {
              'name': r['name'] as String,
              'mole_fraction': (r['mole_fraction'] as num).toDouble(),
            })
        .toList();

    final result = await FluidDefinitionApiService.calculateCompositional(
      {'components': components},
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result['success'] == true ? null : (result['message'] as String?);
      _envelopeData = PhaseEnvelopeData.fromJson(
        result['phase_envelope'] as Map<String, dynamic>?,
      );
      _modelNote = result['model_note'] as String?;
      _eosUsed = result['eos_used'] as String?;
    });
  }

  Future<void> _calculateBlackOil() async {
    setState(() {
      _loading = true;
      _error = null;
      _envelopeData = null;
      _modelNote = null;
    });

    final result = await FluidDefinitionApiService.calculateBlackOil({
      'gor_sm3_sm3': _gorSm3Sm3,
      'water_cut_fraction': _waterCutPercent / 100.0,
      if (_apiGravity != null) 'api_gravity': _apiGravity,
      'include_phase_envelope': true,
    });

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = result['success'] == true ? null : (result['message'] as String?);
      _envelopeData = PhaseEnvelopeData.fromJson(
        result['phase_envelope'] as Map<String, dynamic>?,
      );
      _modelNote = result['model_note'] as String?;
      _eosUsed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Define fluid'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Fluid name', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. North Sea Gas, Well A Black Oil',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Fluid type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Compositional'), icon: Icon(Icons.science)),
                ButtonSegment(value: false, label: Text('Black oil'), icon: Icon(Icons.water_drop)),
              ],
              selected: {_isCompositional},
              onSelectionChanged: (s) => setState(() => _isCompositional = s.first),
            ),
            const SizedBox(height: 24),

            if (_isCompositional) ..._buildCompositionalForm() else ..._buildBlackOilForm(),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_envelopeData != null && !_envelopeData!.isEmpty) ...[
              const SizedBox(height: 24),
              if (_eosUsed != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('EoS: $_eosUsed', style: Theme.of(context).textTheme.bodySmall),
                ),
              const Text('Phase envelope (P–T)', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              PhaseEnvelopeChart(data: _envelopeData),
              if (_modelNote != null && _modelNote!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_modelNote!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCompositionalForm() {
    return [
      const Text('Components (mole fractions must sum to 1.0)', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      ...List.generate(_compositionalRows.length, (i) {
        final row = _compositionalRows[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _componentNames.isNotEmpty
                      ? (_componentNames.contains(row['name']) ? row['name'] as String : _componentNames.first)
                      : 'methane',
                  decoration: const InputDecoration(labelText: 'Component', isDense: true),
                  items: _componentNames.isEmpty
                      ? [const DropdownMenuItem(value: 'methane', child: Text('Loading...'))]
                      : _componentNames.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: _componentNames.isEmpty ? null : (v) {
                    if (v != null) setState(() => _compositionalRows[i]['name'] = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: (row['mole_fraction'] as num).toString(),
                  decoration: const InputDecoration(labelText: 'Mol. frac.', isDense: true),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (s) {
                    final v = double.tryParse(s.replaceAll(',', '.'));
                    if (v != null) setState(() => _compositionalRows[i]['mole_fraction'] = v);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _compositionalRows.length > 1 ? () => _removeCompositionalRow(i) : null,
              ),
            ],
          ),
        );
      }),
      TextButton.icon(
        onPressed: _addCompositionalRow,
        icon: const Icon(Icons.add),
        label: const Text('Add component'),
      ),
      const SizedBox(height: 8),
      Text('Sum: ${_sumMoleFractions().toStringAsFixed(3)}', style: TextStyle(fontSize: 12, color: _sumMoleFractions().abs() - 1.0 < 0.01 ? null : Theme.of(context).colorScheme.error)),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _loading ? null : _calculateCompositional,
        icon: const Icon(Icons.show_chart),
        label: const Text('Calculate phase envelope'),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _saveFluid,
        icon: const Icon(Icons.save),
        label: const Text('Save fluid'),
      ),
    ];
  }

  List<Widget> _buildBlackOilForm() {
    return [
      const Text('GOR (Sm³ gas / Sm³ oil)', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: _gorSm3Sm3.toString(),
        decoration: const InputDecoration(hintText: 'e.g. 100', isDense: true),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (s) {
          final v = double.tryParse(s.replaceAll(',', '.'));
          if (v != null && v >= 0) setState(() => _gorSm3Sm3 = v);
        },
      ),
      const SizedBox(height: 16),
      const Text('Water cut (%)', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: _waterCutPercent.toString(),
        decoration: const InputDecoration(hintText: 'e.g. 70 for 70%', isDense: true),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (s) {
          final v = double.tryParse(s.replaceAll(',', '.'));
          if (v != null && v >= 0 && v <= 100) setState(() => _waterCutPercent = v);
        },
      ),
      const SizedBox(height: 16),
      const Text('API gravity (°API)', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: _apiGravity?.toString() ?? '',
        decoration: const InputDecoration(hintText: 'e.g. 21 (optional)', isDense: true),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (s) {
          final v = double.tryParse(s.replaceAll(',', '.'));
          setState(() => _apiGravity = (v != null && v >= 5 && v <= 60) ? v : null);
        },
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _loading ? null : _calculateBlackOil,
        icon: const Icon(Icons.show_chart),
        label: const Text('Calculate phase envelope'),
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: _saveFluid,
        icon: const Icon(Icons.save),
        label: const Text('Save fluid'),
      ),
    ];
  }
}
