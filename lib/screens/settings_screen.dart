import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _backendUrl;
  late TextEditingController _aiBaseUrl;
  late TextEditingController _aiApiKey;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _backendUrl = TextEditingController();
    _aiBaseUrl = TextEditingController();
    _aiApiKey = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    _backendUrl.text = await SettingsService.getBackendUrl();
    _aiBaseUrl.text = await SettingsService.getAiBaseUrl();
    _aiApiKey.text = await SettingsService.getAiApiKey();
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    await SettingsService.setBackendUrl(_backendUrl.text.trim());
    await SettingsService.setAiBaseUrl(_aiBaseUrl.text.trim());
    await SettingsService.setAiApiKey(_aiApiKey.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  @override
  void dispose() {
    _backendUrl.dispose();
    _aiBaseUrl.dispose();
    _aiApiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Backend (FA API)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _backendUrl,
            decoration: const InputDecoration(
              labelText: 'Base URL (e.g. http://192.168.1.x:8000)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),
          const Text('AI (Chat)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _aiBaseUrl,
            decoration: const InputDecoration(
              labelText: 'AI API base URL',
              hintText: 'https://api.openai.com or Groq free below',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              _aiBaseUrl.text = 'https://api.groq.com/openai/v1';
              setState(() {});
            },
            icon: const Icon(Icons.free_breakfast, size: 20),
            label: const Text('Use Groq (free) – set URL and get key at console.groq.com'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _aiApiKey,
            decoration: const InputDecoration(
              labelText: 'API key',
              hintText: 'OpenAI key or Groq key (free at console.groq.com)',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
