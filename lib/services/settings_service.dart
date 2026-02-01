import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyBackendUrl = 'backend_url';
  static const _keyAiBaseUrl = 'ai_base_url';
  static const _keyAiApiKey = 'ai_api_key';

  /// Default: ngrok tunnel (works for mobile, emulator, Chrome). Change in Settings if you use a different tunnel or localhost.
  static Future<String> getBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBackendUrl) ??
        'https://interavailable-heaping-marianela.ngrok-free.dev';
  }

  static Future<void> setBackendUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBackendUrl, url);
  }

  static Future<String> getAiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAiBaseUrl) ?? 'https://api.openai.com';
  }

  static Future<void> setAiBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAiBaseUrl, url);
  }

  static Future<String> getAiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAiApiKey) ?? '';
  }

  static Future<void> setAiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAiApiKey, key);
  }
}
