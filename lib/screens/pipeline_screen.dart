import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/pipe_layer.dart';
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
  final List<PipeLayer> _pipeLayers = [];
  String? _environment;
  static const _materials = ['carbon_steel', 'stainless_steel', 'GRE'];
  static const _environments = ['subsea', 'buried', 'land'];

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

  Widget _buildProfileChart() {
    if (_points.length < 2) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('Add at least 2 points for profile')),
      );
    }
    final lengthMax = _points.map((p) => p.horizontalLengthM).reduce((a, b) => a > b ? a : b);
    final lengthMin = _points.map((p) => p.horizontalLengthM).reduce((a, b) => a < b ? a : b);
    final elevMax = _points.map((p) => p.elevationM).reduce((a, b) => a > b ? a : b);
    final elevMin = _points.map((p) => p.elevationM).reduce((a, b) => a < b ? a : b);
    final lengthRange = (lengthMax - lengthMin).clamp(1.0, double.infinity);
    final elevRange = (elevMax - elevMin).clamp(1.0, double.infinity);
    final spots = _points
        .map((p) => FlSpot(
              p.horizontalLengthM.toDouble(),
              p.elevationM,
            ))
        .toList();
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: lengthMin - lengthRange * 0.02,
          maxX: lengthMax + lengthRange * 0.02,
          minY: elevMin - elevRange * 0.05,
          maxY: elevMax + elevRange * 0.05,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          gridData: const FlGridData(show: true, drawVerticalLine: true, drawHorizontalLine: true),
        ),
        duration: const Duration(milliseconds: 150),
      ),
    );
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pipeline profile', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Elevation (m) vs Length (m)', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          _buildProfileChart(),
                        ],
                      ),
                    ),
                  ),
                  if (widget.isEngineering) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Text('Environment:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          DropdownButton<String?>(
                            value: _environment,
                            hint: const Text('Optional'),
                            items: [
                              const DropdownMenuItem<String?>(value: null, child: Text('—')),
                              ..._environments.map((e) => DropdownMenuItem<String?>(value: e, child: Text(e))),
                            ],
                            onChanged: (v) => setState(() => _environment = v),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('Wall layers (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => setState(() => _pipeLayers.add(PipeLayer(material: _materials.first, thicknessInch: 0.2))),
                            icon: const Icon(Icons.add),
                            label: const Text('Add layer'),
                          ),
                        ],
                      ),
                    ),
                    if (_pipeLayers.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _pipeLayers.length,
                        itemBuilder: (context, i) {
                          final layer = _pipeLayers[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: layer.material,
                                      decoration: const InputDecoration(labelText: 'Material', isDense: true),
                                      items: _materials.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                      onChanged: (v) => setState(() => _pipeLayers[i] = PipeLayer(material: v ?? layer.material, thicknessInch: layer.thicknessInch)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      initialValue: layer.thicknessInch.toString(),
                                      decoration: const InputDecoration(labelText: 'in', isDense: true),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (v) {
                                        final x = double.tryParse(v);
                                        if (x != null && x >= 0) setState(() => _pipeLayers[i] = PipeLayer(material: layer.material, thicknessInch: x));
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => setState(() => _pipeLayers.removeAt(i)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                ],
              ),
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
                        pipeLayers: _pipeLayers.isEmpty ? null : List.from(_pipeLayers),
                        environment: _environment,
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
