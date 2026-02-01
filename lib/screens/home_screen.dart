import 'package:flutter/material.dart';

import 'pipeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Assurance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToPipeline(context, isEngineering: true),
              icon: const Icon(Icons.calculate),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Engineering (correlation)'),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _navigateToPipeline(context, isEngineering: false),
              icon: const Icon(Icons.chat),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Chat with AI'),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPipeline(BuildContext context, {required bool isEngineering}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PipelineScreen(isEngineering: isEngineering),
      ),
    );
  }
}
