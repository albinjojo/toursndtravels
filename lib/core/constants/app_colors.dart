import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF1A6FC4);
  static const Color primaryBg = Color(0xFFEFF6FF);

  static const Color background = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textMedium = Color(0xFF374151);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderSeparator = Color(0xFFE5E7EB);

  // Trip type badge colours
  static const Color firstTripBg = Color(0xFFCFFAFE);
  static const Color firstTripText = Color(0xFF155E75);
  static const Color secondTripBg = Color(0xFFEDE9FE);
  static const Color secondTripText = Color(0xFF4C1D95);

  // Avatar palette – cycled by name hash
  static const List<(Color bg, Color fg)> avatarPalette = [
    (Color(0xFFDBEAFE), Color(0xFF1E3A8A)),
    (Color(0xFFD1FAE5), Color(0xFF065F46)),
    (Color(0xFFEDE9FE), Color(0xFF4C1D95)),
    (Color(0xFFFEE2E2), Color(0xFF991B1B)),
  ];

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);

  // Nav
  static const Color navActiveBg = Color(0xFFE8F1FC);
  static const Color navInactive = Color(0xFF9CA3AF);

  // School card accent index colours
  static const List<(Color bg, Color icon)> schoolPalette = [
    (Color(0xFFDBEAFE), Color(0xFF1A6FC4)),
    (Color(0xFFD1FAE5), Color(0xFF059669)),
    (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
    (Color(0xFFFEF3C7), Color(0xFFD97706)),
  ];
}
