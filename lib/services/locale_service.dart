import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'app_locale';
  static const Locale defaultLocale = Locale('ar', 'SA');
  
  static final List<Locale> supportedLocales = [
    const Locale('ar', 'SA'),
    const Locale('en', 'US'),
  ];

  /// Get saved locale or return default
  static Future<Locale> getLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      
      if (localeCode != null) {
        final parts = localeCode.split('_');
        if (parts.length == 2) {
          return Locale(parts[0], parts[1]);
        } else if (parts.length == 1) {
          return Locale(parts[0]);
        }
      }
    } catch (e) {
      print('Error getting locale: $e');
    }
    
    return defaultLocale;
  }

  /// Save locale preference
  static Future<bool> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      return await prefs.setString(_localeKey, localeCode);
    } catch (e) {
      print('Error saving locale: $e');
      return false;
    }
  }

  /// Check if locale is RTL
  static bool isRTL(Locale locale) {
    return locale.languageCode == 'ar';
  }

  /// Get text direction for locale
  static TextDirection getTextDirection(Locale locale) {
    return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }
}






