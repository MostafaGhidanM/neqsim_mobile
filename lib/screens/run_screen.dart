import 'package:flutter/material.dart';

import '../models/fluid_input.dart';
import '../models/pipeline_point.dart';
import '../services/fa_api_service.dart';
import 'results_screen.dart';

class RunScreen extends StatefulWidget {
  final List<PipelinePoint> points;
  final FluidInput fluid;

  const RunScreen({
    super.key,
    required this.points,
    required this.fluid,
  });

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final pointsJson = widget.points.map((p) => p.toJson()).toList();
    final body = widget.fluid.toFaRequestJson(pointsJson);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pipeline', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${widget.points.length} points'),
                  const SizedBox(height: 8),
                  const Text('Fluid', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('T = ${widget.fluid.temperatureC} °C, P = ${widget.fluid.pressureBara} bara'),
                  Text('Flow = ${widget.fluid.flowRate} ${widget.fluid.flowUnit}'),
                  Text('Type: ${widget.fluid.fluidType}, preset: ${widget.fluid.preset}'),
                  Text('Diameter = ${widget.fluid.diameterM} m, roughness = ${widget.fluid.roughnessM} m'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        final result = await FaApiService.calculate(body);
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultsScreen(response: result),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Calculate'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
