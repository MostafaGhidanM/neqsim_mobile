import 'dart:convert';

import 'package:http/http.dart' as http;

import 'settings_service.dart';

class AiChatService {
  static Future<String?> sendMessage({
    required String systemContext,
    required String userMessage,
    String model = 'gpt-3.5-turbo',
  }) async {
    final baseUrl = (await SettingsService.getAiBaseUrl()).trim();
    final apiKey = (await SettingsService.getAiApiKey()).trim();
    if (apiKey.isEmpty) {
      return 'Please set your API key in Settings (Chat → Settings → AI API key).';
    }
    if (baseUrl.isEmpty) {
      return 'Please set AI API base URL in Settings (e.g. https://api.openai.com or Groq free: https://api.groq.com/openai/v1).';
    }
    // Groq (free tier): use Groq model; base URL is already .../openai/v1
    final isGroq = baseUrl.toLowerCase().contains('groq');
    final modelToUse = isGroq ? 'llama-3.1-8b-instant' : model;
    final String chatUrl = baseUrl.contains('/v1') || baseUrl.endsWith('/v1')
        ? (baseUrl.endsWith('/') ? '${baseUrl}chat/completions' : '$baseUrl/chat/completions')
        : (baseUrl.endsWith('/') ? '${baseUrl}v1/chat/completions' : '$baseUrl/v1/chat/completions');
    final uri = Uri.parse(chatUrl);
    final body = {
      'model': modelToUse,
      'messages': [
        {'role': 'system', 'content': systemContext},
        {'role': 'user', 'content': userMessage},
      ],
    };
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        String errMsg = 'API error (${response.statusCode})';
        try {
          final errMap = jsonDecode(response.body) as Map<String, dynamic>?;
          final err = errMap?['error'];
          if (err is Map<String, dynamic> && err['message'] != null) {
            errMsg = err['message'] as String;
          } else if (errMap?['message'] != null) {
            errMsg = errMap!['message'] as String;
          }
        } catch (_) {
          if (response.body.isNotEmpty && response.body.length < 200) {
            errMsg = response.body;
          }
        }
        return 'Error: $errMsg';
      }

      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = map['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        return 'No reply from AI. Try again or check model name.';
      }
      final content = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
      return content?['content'] as String?;
    } on http.ClientException catch (e) {
      return 'Cannot reach AI API: ${e.message}. Check base URL and internet.';
    } on Exception catch (e) {
      return 'Request failed: $e';
    }
  }
}
