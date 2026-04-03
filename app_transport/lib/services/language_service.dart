import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const _kLocaleCodeKey = 'app_locale_code';

  Locale _locale = const Locale('en');
  bool _loaded = false;

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_kLocaleCodeKey);

    if (savedCode == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    final normalized = (code == 'ar') ? 'ar' : 'en';
    if (_locale.languageCode == normalized) return;

    _locale = Locale(normalized);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleCodeKey, normalized);
  }
}
