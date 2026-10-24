import 'package:shared_preferences/shared_preferences.dart';

class PreferenceRepository {
  final SharedPreferences _sharedPrefs;
  static const _isDarkKey = 'isDark';
  static const _languageKey = 'languageCode';
  static const _railExtendedKey = 'railExtended';

  PreferenceRepository(this._sharedPrefs);

  bool get isDark => _sharedPrefs.getBool(_isDarkKey) ?? false;

  /// Chosen language ('en' / 'sw'); null until the user picks one.
  String? get languageCode => _sharedPrefs.getString(_languageKey);

  /// Whether the side navigation shows labels.
  bool get isRailExtended => _sharedPrefs.getBool(_railExtendedKey) ?? true;

  Future<void> setDarkMode({bool isDark = false}) async {
    await _sharedPrefs.setBool(_isDarkKey, isDark);
  }

  Future<void> setLanguage(String languageCode) async {
    await _sharedPrefs.setString(_languageKey, languageCode);
  }

  Future<void> setRailExtended(bool value) async {
    await _sharedPrefs.setBool(_railExtendedKey, value);
  }
}
