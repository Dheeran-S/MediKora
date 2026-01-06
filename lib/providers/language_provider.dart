import 'package:flutter/foundation.dart';
import 'package:app/services/localization_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _currentLanguage = LocalizationService.getCurrentLanguage();
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      await LocalizationService.setLanguage(languageCode);
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }

  String translate(String key) {
    return LocalizationService.translate(key);
  }

  List<Map<String, String>> getSupportedLanguages() {
    return LocalizationService.getSupportedLanguages();
  }
}
