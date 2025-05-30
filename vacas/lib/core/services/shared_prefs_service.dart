import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Métodos de ejemplo:
  static Future<void> setString(String key, String value) async {
    await instance.setString(key, value);
  }

  static String? getString(String key) {
    return instance.getString(key);
  }

  static Future<void> remove(String key) async {
    await instance.remove(key);
  }
}
