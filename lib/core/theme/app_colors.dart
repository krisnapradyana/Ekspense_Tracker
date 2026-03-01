import 'package:flutter/material.dart';

/// Define core palette and dynamic theme logic based on remaining budget.
class AppColors {
  // Base Colors (Sage Green Palette)
  static const Color sagePrimary = Color(0xFF789B84); // Sage Green
  static const Color sageSecondary = Color(0xFFA0C0AB);
  static const Color sageBackground = Color(0xFFF2F5F3);
  static const Color sageSurface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E35);
  static const Color textSecondary = Color(0xFF6A8A76);

  // Warning Colors (Subtle Red Palette)
  static const Color warningRed = Color(0xFFD98A84); // Soft Terracotta/Coral
  static const Color warningBackground = Color(0xFFFFF5F4);

  /// Menghitung warna dinamis berdasarkan persentase budget yang terpakai.
  /// Jika persentase mendekati 1.0 (habis), warna akan bertransisi ke warningRed secara perlahan.
  static Color getDynamicColor(double percentageSpent) {
    final double safePercentage = percentageSpent.clamp(0.0, 1.0);
    return Color.lerp(sagePrimary, warningRed, safePercentage) ?? sagePrimary;
  }
}
