import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_fluid.dart';

/// Persistent storage key. Data is stored via [SharedPreferences] and survives
/// app restarts and device reboots (same as app data).
const String _keySavedFluids = 'saved_fluids';

class SavedFluidsService {
  /// Load saved fluids from persistent storage. Restored after every app launch.
  static Future<List<SavedFluid>> getSavedFluids() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySavedFluids);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((e) => SavedFluid.fromJson(e as Map<String, dynamic>))
          .whereType<SavedFluid>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save fluid to persistent device storage. Available after every app restart.
  static Future<void> saveFluid(SavedFluid fluid) async {
    final list = await getSavedFluids();
    final index = list.indexWhere((f) => f.id == fluid.id);
    final updated = List<SavedFluid>.from(list);
    if (index >= 0) {
      updated[index] = fluid;
    } else {
      updated.add(fluid);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keySavedFluids,
      jsonEncode(updated.map((f) => f.toJson()).toList()),
    );
  }

  static Future<void> deleteFluid(String id) async {
    final list = await getSavedFluids();
    final updated = list.where((f) => f.id != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keySavedFluids,
      jsonEncode(updated.map((f) => f.toJson()).toList()),
    );
  }
}
