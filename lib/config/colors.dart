import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية - تصميم جديد
  static const Color primary = Color(0xFFD62828);      // أحمر (اللون الأساسي)
  static const Color primaryLight = Color(0xFFEF4444);  // أحمر فاتح
  static const Color primaryDark = Color(0xFFB91C1C);    // أحمر داكن
  static const Color secondary = Color(0xFF213F6A);     // أزرق داكن (لون الخط الأول)
  static const Color secondaryLight = Color(0xFF3B5A7F); // أزرق فاتح
  static const Color accent = Color(0xFFD62828);        // نفس اللون الأساسي
  static const Color success = Color(0xFF10B981);      // أخضر نجاح
  static const Color error = Color(0xFFD62828);        // أحمر (نفس الأساسي)
  static const Color warning = Color(0xFFF59E0B);       // برتقالي تحذير
  static const Color info = Color(0xFF213F6A);         // أزرق داكن (معلومات)
  
  // ألوان الخلفية
  static const Color background = Color(0xFFE8E8E8);    // رمادي فاتح (لون الخلفية)
  static const Color backgroundLight = Color(0xFFF5F5F5); // رمادي فاتح جداً
  static const Color surface = Color(0xFFFFFFFF);      // أبيض نقي
  static const Color card = Color(0xFFFFFFFF);         // أبيض للبطاقات
  
  // ألوان النص
  static const Color textPrimary = Color(0xFF213F6A);   // أزرق داكن (لون الخط الأول)
  static const Color textSecondary = Color(0xFF333333); // رمادي داكن (لون الخط الثاني)
  static const Color textDisabled = Color(0xFF9CA3AF); // رمادي فاتح
  static const Color textInverse = Color(0xFFFFFFFF);   // أبيض
  
  // ألوان الحدود
  static const Color border = Color(0xFFD1D5DB);       // رمادي فاتح للحدود
  static const Color divider = Color(0xFFE5E7EB);      // رمادي فاتح للفواصل
  
  // التدرجات اللونية - تصميم جديد
  static const List<Color> gradientPrimary = [
    Color(0xFFD62828),
    Color(0xFFB91C1C),
  ];
  
  static const List<Color> gradientSecondary = [
    Color(0xFF213F6A),
    Color(0xFF1E3A8A),
  ];
  
  static const List<Color> gradientMedical = [
    Color(0xFFD62828),
    Color(0xFFB91C1C),
  ];
  
  static const List<Color> gradientSuccess = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];
  
  static const List<Color> gradientError = [
    Color(0xFFD62828),
    Color(0xFFB91C1C),
  ];
  
  // ألوان إضافية
  static const Color medicalBlue = Color(0xFF213F6A);   // أزرق داكن
  static const Color medicalTeal = Color(0xFF213F6A);  // أزرق داكن
  static const Color medicalGreen = Color(0xFF10B981); // أخضر
}

