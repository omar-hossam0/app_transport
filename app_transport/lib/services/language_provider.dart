import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  String get langCode => _locale.languageCode;

  void setLanguage(String langName) {
    if (langName == 'العربية' || langName == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
