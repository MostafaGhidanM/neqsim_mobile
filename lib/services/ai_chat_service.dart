import 'dart:convert';

import 'package:http/http.dart' as http;

import 'settings_service.dart';

class AiChatService {
  static Future<String?> sendMessage({
    required String systemContext,
    required String userMessage,
    String model = 'gpt-3.5-turbo',
  }) async {
    final baseUrl = await SettingsService.getAiBaseUrl();
    final apiKey = await SettingsService.getAiApiKey();
    if (apiKey.isEmpty) return null;
    final uri = Uri.parse('$baseUrl/v1/chat/completions');
    final body = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemContext},
        {'role': 'user', 'content': userMessage},
      ],
    };
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) return null;
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = map['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;
    final content = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
    return content?['content'] as String?;
  }
}
