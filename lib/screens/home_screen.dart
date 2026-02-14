import 'package:flutter/material.dart';

import 'define_fluid_screen.dart';
import 'pipeline_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Simulation'),
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
              'Quick actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _QuickActionButton(
              icon: Icons.water_drop,
              label: 'Define fluid',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DefineFluidScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.calculate,
              label: 'Flow assurance',
              onPressed: () => _navigateToPipeline(context, isEngineering: true),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.filter_alt,
              label: 'Separator',
              onPressed: () => _showComingSoon(context, 'Separator'),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.precision_manufacturing,
              label: 'Pump',
              onPressed: () => _showComingSoon(context, 'Pump'),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.ac_unit,
              label: 'Air cooler',
              onPressed: () => _showComingSoon(context, 'Air cooler'),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.thermostat,
              label: 'Heat exchanger',
              onPressed: () => _showComingSoon(context, 'Heat exchanger'),
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

  void _showComingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name – Coming soon')),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }
}
