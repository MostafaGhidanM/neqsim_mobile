import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fa_response.dart';
import 'settings_service.dart';

class FaApiService {
  static String _normalizeBaseUrl(String url) {
    final u = url.trim();
    return u.endsWith('/') ? u.substring(0, u.length - 1) : u;
  }

  static Future<FaResponse> calculate(Map<String, dynamic> body) async {
    final baseUrl = _normalizeBaseUrl(await SettingsService.getBackendUrl());
    final uri = Uri.parse('$baseUrl/flow-assurance/calculate');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 404) {
        return FaResponse(
          success: false,
          message: '404: Flow-assurance API not found at this URL. '
              'Start the NeqSim API with flow_assurance.py (e.g. uvicorn examples.process_api:app --host 0.0.0.0 --port 8000) and point ngrok to that port.',
        );
      }
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final fa = FaResponse.fromJson(map);
      if (response.statusCode != 200) {
        return FaResponse(
          success: false,
          message: fa.message.isNotEmpty ? fa.message : 'HTTP ${response.statusCode}',
        );
      }
      return fa;
    } on http.ClientException catch (e) {
      return FaResponse(
        success: false,
        message: 'Cannot reach server: ${e.message}. '
            'Check: (1) Server running? (2) Settings → Backend URL: use http://10.0.2.2:8000 for Android emulator, http://YOUR_PC_IP:8000 for real device.',
      );
    } on Exception catch (e) {
      return FaResponse(success: false, message: 'Request failed: $e');
    }
  }

  static Future<Map<String, List<String>>?> getFluidPresets() async {
    final baseUrl = _normalizeBaseUrl(await SettingsService.getBackendUrl());
    final uri = Uri.parse('$baseUrl/flow-assurance/fluid-presets');
    try {
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode != 200) return null;
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'black_oil': (map['black_oil'] as List).cast<String>(),
        'compositional': (map['compositional'] as List).cast<String>(),
      };
    } catch (_) {
      return null;
    }
  }
}
