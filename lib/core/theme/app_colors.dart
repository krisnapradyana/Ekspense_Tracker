import 'package:flutter/material.dart';

/// Define core palette and dynamic theme logic based on remaining budget.
class AppColors {
  // ─── Light Palette (Sage Green) ───
  static const Color sagePrimary = Color(0xFF789B84);
  static const Color sageSecondary = Color(0xFFA0C0AB);
  static const Color lightBackground = Color(0xFFF2F5F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2C3E35);
  static const Color lightTextSecondary = Color(0xFF6A8A76);

  // ─── Dark Palette ───
  static const Color darkBackground = Color(0xFF1A1E1B);
  static const Color darkSurface = Color(0xFF252B27);
  static const Color darkTextPrimary = Color(0xFFE2E8E4);
  static const Color darkTextSecondary = Color(0xFF9AB3A2);

  // ─── Warning Colors (same for both modes) ───
  static const Color warningRed = Color(0xFFD98A84);
  static const Color warningBackground = Color(0xFFFFF5F4);


  /// Menghitung warna dinamis berdasarkan persentase budget yang terpakai.
  static Color getDynamicColor(double percentageSpent) {
    final double safePercentage = percentageSpent.clamp(0.0, 1.0);
    return Color.lerp(sagePrimary, warningRed, safePercentage) ?? sagePrimary;
  }
}
