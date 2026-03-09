import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/app_strings.dart';

class SettingsController with ChangeNotifier {
  String _currentLanguage = 'id';
  bool _isFirstLaunch = true;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  String get currentLanguage => _currentLanguage;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  SettingsController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'id';
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _currentLanguage);
      await prefs.setBool('isFirstLaunch', _isFirstLaunch);
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint("Error saving settings: $e");
    }
  }

  void setLanguage(String langCode) {
    if (_currentLanguage != langCode) {
      _currentLanguage = langCode;
      notifyListeners();
      saveSettings();
    }
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    saveSettings();
  }

  void completeFirstLaunch() {
    if (_isFirstLaunch) {
      _isFirstLaunch = false;
      notifyListeners();
      saveSettings();
    }
  }

  // Helper method to get localized string via key
  String getString(String key) {
    return AppStrings.translations[_currentLanguage]?[key] ?? key;
  }
}
