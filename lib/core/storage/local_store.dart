import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = (await prefs).getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeJson(String key, Map<String, Object?> value) async {
    await (await prefs).setString(key, jsonEncode(value));
  }

  Future<String?> readString(String key) async => (await prefs).getString(key);

  Future<void> writeString(String key, String value) async =>
      (await prefs).setString(key, value);

  Future<bool> readBool(String key, {bool fallback = false}) async =>
      (await prefs).getBool(key) ?? fallback;

  Future<void> writeBool(String key, bool value) async =>
      (await prefs).setBool(key, value);

  Future<void> remove(String key) async => (await prefs).remove(key);
}
