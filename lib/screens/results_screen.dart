import 'package:flutter/material.dart';

import '../models/fa_response.dart';

class ResultsScreen extends StatelessWidget {
  final FaResponse response;

  const ResultsScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          response.success ? Icons.check_circle : Icons.warning,
                          color: response.success ? Colors.green : Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          response.success ? 'Success' : 'Warning / Error',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: response.success ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    if (response.startingPressureBara != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Starting pressure: ${response.startingPressureBara!.toStringAsFixed(2)} bara',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (response.evr != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'EVR: ${response.evr!.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (response.iterationsUsed != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Iterations: ${response.iterationsUsed} / 100',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                    if (response.message.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(response.message),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
