import 'package:flutter/material.dart';

import '../models/pipeline_point.dart';
import 'fluid_screen.dart';

class PipelineScreen extends StatefulWidget {
  final bool isEngineering;

  const PipelineScreen({super.key, required this.isEngineering});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final List<PipelinePoint> _points = [
    PipelinePoint(horizontalLengthM: 0, elevationM: 0),
    PipelinePoint(horizontalLengthM: 1000, elevationM: 0),
  ];

  void _addRow() {
    setState(() {
      final last = _points.isEmpty ? PipelinePoint(horizontalLengthM: 0, elevationM: 0) : _points.last;
      _points.add(PipelinePoint(
        horizontalLengthM: last.horizontalLengthM + 500,
        elevationM: last.elevationM,
      ));
    });
  }

  void _removeAt(int i) {
    if (_points.length <= 2) return;
    setState(() => _points.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pipeline'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Length (m) / Elevation (m) per point'),
                FilledButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add row'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _points.length,
              itemBuilder: (context, i) {
                final p = _points[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: p.horizontalLengthM.toString(),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Length (m)',
                              isDense: true,
                            ),
                            onChanged: (v) {
                              final x = double.tryParse(v);
                              if (x != null) {
                                setState(() => _points[i] = p.copyWith(horizontalLengthM: x));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: p.elevationM.toString(),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Elevation (m)',
                              isDense: true,
                            ),
                            onChanged: (v) {
                              final x = double.tryParse(v);
                              if (x != null) {
                                setState(() => _points[i] = p.copyWith(elevationM: x));
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _points.length > 2 ? () => _removeAt(i) : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_points.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('At least 2 points required')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FluidScreen(
                        points: List.from(_points),
                        isEngineering: widget.isEngineering,
                      ),
                    ),
                  );
                },
                child: const Text('Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
