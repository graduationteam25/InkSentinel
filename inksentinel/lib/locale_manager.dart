// locale_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleManager extends ChangeNotifier {
  static const String localeKey = 'selected_locale';
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  LocaleManager() {
    _loadLocale();
  }

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ar', 'EG'), // Arabic (Egypt)
  ];
  void setLocale(Locale newLocale) {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      notifyListeners();
    }
  }

  // Language options with display names
  static const Map<String, LanguageInfo> languageOptions = {
    'en': LanguageInfo(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
      locale: Locale('en', 'US'),
    ),
    'ar': LanguageInfo(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇪🇬',
      locale: Locale('ar', 'EG'),
    ),
  };

  // Load saved locale from shared preferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(localeKey) ?? 'en';
      
      // Find the locale from supported locales
      final savedLocale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
        orElse: () => supportedLocales.first,
      );
      
      _currentLocale = savedLocale;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale: $e');
      // Fallback to English
      _currentLocale = const Locale('en', 'US');
      notifyListeners();
    }
  }

  // Change the app language
  Future<void> changeLanguage(String languageCode) async {
    try {
      final newLocale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == languageCode,
        orElse: () => supportedLocales.first,
      );
      
      if (_currentLocale != newLocale) {
        _currentLocale = newLocale;
        await _saveLocale();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error changing language: $e');
    }
  }

  // Get language info by code
  LanguageInfo? getLanguageInfo(String languageCode) {
    return languageOptions[languageCode];
  }

  // Get current language info
  LanguageInfo get currentLanguageInfo {
    return languageOptions[_currentLocale.languageCode] ?? 
           languageOptions['en']!;
  }

  // Save locale to shared preferences
  Future<void> _saveLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(localeKey, _currentLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  // Toggle between English and Arabic (for quick switching)
  Future<void> toggleLanguage() async {
    final newLanguageCode = isEnglish ? 'ar' : 'en';
    await changeLanguage(newLanguageCode);
  }
}

// Language information model
class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}