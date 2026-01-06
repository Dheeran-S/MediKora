import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  static Map<String, dynamic>? _translations;
  static String _currentLanguage = _defaultLanguage;

  static Future<void> init() async {
    await _loadLanguage();
    await _loadTranslations();
  }

  static Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  static Future<void> _loadTranslations() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/languages/$_currentLanguage.json');
      Map<String, dynamic> translations = json.decode(jsonString);
      _translations = translations;
    } catch (e) {
      // Fallback to English if translation file not found
      String jsonString = await rootBundle
          .loadString('assets/languages/$_defaultLanguage.json');
      Map<String, dynamic> translations = json.decode(jsonString);
      _translations = translations;
    }
  }

  static Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      await _loadTranslations();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    }
  }

  static String getCurrentLanguage() {
    return _currentLanguage;
  }

  static String translate(String key) {
    if (_translations == null) return key;

    List<String> keys = key.split('.');
    dynamic value = _translations;

    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }

    return value.toString();
  }

  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English'},
      {'code': 'ta', 'name': 'தமிழ்'},
      {'code': 'hi', 'name': 'हिंदी'},
    ];
  }
}
