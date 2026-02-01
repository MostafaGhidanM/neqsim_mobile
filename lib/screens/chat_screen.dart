import 'package:flutter/material.dart';

import '../models/fluid_input.dart';
import '../models/pipeline_point.dart';
import '../services/ai_chat_service.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  final List<PipelinePoint> points;
  final FluidInput fluid;

  const ChatScreen({
    super.key,
    required this.points,
    required this.fluid,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<MapEntry<bool, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  String _buildContextSummary() {
    final lengths = widget.points.map((p) => p.horizontalLengthM.toStringAsFixed(0)).join(', ');
    final elevations = widget.points.map((p) => p.elevationM.toStringAsFixed(0)).join(', ');
    return 'Flow assurance scenario: Pipeline with ${widget.points.length} points. '
        'Lengths (m): [$lengths]. Elevations (m): [$elevations]. '
        'Fluid: ${widget.fluid.fluidType}, preset ${widget.fluid.preset}. '
        'T = ${widget.fluid.temperatureC} °C, P = ${widget.fluid.pressureBara} bara, '
        'flow = ${widget.fluid.flowRate} ${widget.fluid.flowUnit}. '
        'Pipe diameter = ${widget.fluid.diameterM} m, roughness = ${widget.fluid.roughnessM} m.';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    _controller.clear();
    setState(() {
      _messages.add(const MapEntry(true, ''));
      _messages[_messages.length - 1] = MapEntry(true, text);
    });
    setState(() => _loading = true);
    final contextSummary = _buildContextSummary();
    try {
      final reply = await AiChatService.sendMessage(
        systemContext: 'You are a flow assurance engineer. Use this scenario as context: $contextSummary',
        userMessage: text,
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messages.add(MapEntry(false, reply ?? 'No response. Check Settings: AI base URL and API key.'));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messages.add(MapEntry(false, 'Error: $e'));
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _buildContextSummary(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._messages.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: e.key ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: e.key
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(e.value),
                        ),
                      ),
                    )),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask about flow assurance...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _loading ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
