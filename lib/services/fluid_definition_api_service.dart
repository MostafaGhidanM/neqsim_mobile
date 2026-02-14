import 'dart:convert';

import 'package:http/http.dart' as http;

import 'settings_service.dart';

class FluidDefinitionApiService {
  static String _normalizeBaseUrl(String url) {
    final u = url.trim();
    return u.endsWith('/') ? u.substring(0, u.length - 1) : u;
  }

  static Future<List<String>> getComponentNames() async {
    final baseUrl = _normalizeBaseUrl(await SettingsService.getBackendUrl());
    final uri = Uri.parse('$baseUrl/fluid-definition/component-names');
    try {
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode != 200) return _defaultComponentNames();
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final list = map['component_names'];
      if (list is List) return list.cast<String>();
      return _defaultComponentNames();
    } catch (_) {
      return _defaultComponentNames();
    }
  }

  static List<String> _defaultComponentNames() {
    return [
      'nitrogen', 'CO2', 'methane', 'ethane', 'propane', 'i-butane', 'n-butane',
      'i-pentane', 'n-pentane', 'n-hexane', 'n-heptane', 'n-octane', 'water', 'H2S',
    ];
  }

  static Future<Map<String, List<String>>> getFluidPresets() async {
    final baseUrl = _normalizeBaseUrl(await SettingsService.getBackendUrl());
    final uri = Uri.parse('$baseUrl/fluid-definition/fluid-presets');
    try {
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode != 200) return _defaultPresets();
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'compositional': (map['compositional'] as List?)?.cast<String>() ?? ['dry gas', 'rich gas'],
        'black_oil': (map['black_oil'] as List?)?.cast<String>() ?? ['black oil', 'light oil'],
      };
    } catch (_) {
      return _defaultPresets();
    }
  }

  static Map<String, List<String>> _defaultPresets() {
    return {
      'compositional': ['dry gas', 'rich gas'],
      'black_oil': ['black oil', 'light oil'],
    };
  }

  /// POST /fluid-definition/compositional
  /// Returns { success, message, phase_envelope: { dew_point_t_k, dew_point_p_bara, ... } }
  static Future<Map<String, dynamic>> calculateCompositional(Map<String, dynamic> body) async {
    final baseUrl = _normalizeBaseUrl(await SettingsService.getBackendUrl());
    final uri = Uri.parse('$baseUrl/fluid-definition/compositional');
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
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': map['detail'] ?? map['message'] ?? 'HTTP ${response.statusCode}',
          'phase_envelope': null,
        };
      }
      return map;
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Cannot reach server: ${e.message}. Check Settings → Backend URL.',
        'phase_envelope': null,
      };
    } on Exception catch (e) {
      return {'success': false, 'message': 'Request failed: $e', 'phase_envelope': null};
    }
  }

  /// POST /fluid-definition/black-oil
  /// Returns { success, preset_used?, message, phase_envelope? }
  static Future<Map<String, dynamic>> calculateBlackOil(Map<String, dynamic> body) async {
    final baseUrl = _normalizeBaseUrl(await SettingsService.getBackendUrl());
    final uri = Uri.parse('$baseUrl/fluid-definition/black-oil');
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
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': map['detail'] ?? map['message'] ?? 'HTTP ${response.statusCode}',
          'phase_envelope': null,
        };
      }
      return map;
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Cannot reach server: ${e.message}. Check Settings → Backend URL.',
        'phase_envelope': null,
      };
    } on Exception catch (e) {
      return {'success': false, 'message': 'Request failed: $e', 'phase_envelope': null};
    }
  }
}
