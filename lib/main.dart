import 'package:flutter/material.dart';
import 'screens/define_fluid_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const NeqSimApp());
}

class NeqSimApp extends StatelessWidget {
  const NeqSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Process Simulation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/define-fluid': (context) => const DefineFluidScreen(),
      },
    );
  }
}
