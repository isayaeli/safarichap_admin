import 'package:flutter/material.dart';
import '../../data/repositories/preferences_repository.dart';

class ThemeManager with ChangeNotifier {
  final PreferenceRepository _preferenceRepository;

  bool get isDark => _preferenceRepository.isDark;

  ThemeManager(this._preferenceRepository);

  Future<void> toggleTheme({required bool isDark}) async {
    await _preferenceRepository.setDarkMode(isDark: isDark);
    notifyListeners();
  }
}
