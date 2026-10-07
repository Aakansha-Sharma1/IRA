import 'package:flutter/material.dart';

/// Centralized IRA visual tokens.
abstract final class AppColors {
  // Brand spectrum
  static const Color primary = Color(0xFF6475FF);
  static const Color primaryLight = Color(0xFF8D9BFF);
  static const Color primaryDark = Color(0xFF4654D7);
  static const Color secondary = Color(0xFFB26CFF);
  static const Color secondaryLight = Color(0xFFD19AFF);
  static const Color secondaryDark = Color(0xFF8748D8);
  static const Color tertiary = Color(0xFFFF78B7);
  static const Color accentBlue = Color(0xFF4CC9F0);
  static const Color accentPink = Color(0xFFFF8CC6);

  static const Color primaryContainerLight = Color(0xFFE7E9FF);
  static const Color primaryContainerDark = Color(0xFF303779);
  static const Color secondaryContainerLight = Color(0xFFF1E6FF);
  static const Color secondaryContainerDark = Color(0xFF4E2C73);

  // Neutrals
  static const Color neutral50 = Color(0xFFF8F7FF);
  static const Color neutral100 = Color(0xFFF0EEFA);
  static const Color neutral200 = Color(0xFFDDD9ED);
  static const Color neutral300 = Color(0xFFC5C0D8);
  static const Color neutral400 = Color(0xFFA29DB8);
  static const Color neutral500 = Color(0xFF7B7692);
  static const Color neutral600 = Color(0xFF5D5872);
  static const Color neutral700 = Color(0xFF3E3A52);
  static const Color neutral800 = Color(0xFF29263B);
  static const Color neutral900 = Color(0xFF171525);
  static const Color neutral950 = Color(0xFF0B0915);

  // Light surfaces
  static const Color backgroundLight = Color(0xFFF7F5FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0EEFA);
  static const Color textPrimaryLight = Color(0xFF1B1830);
  static const Color textSecondaryLight = Color(0xFF5D5872);
  static const Color textMutedLight = Color(0xFF858099);
  static const Color borderLight = Color(0xFFE1DDF0);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF0D0B1C);
  static const Color surfaceDark = Color(0xFF19162D);
  static const Color surfaceVariantDark = Color(0xFF26213F);
  static const Color textPrimaryDark = Color(0xFFF8F6FF);
  static const Color textSecondaryDark = Color(0xFFC1BAD4);
  static const Color textMutedDark = Color(0xFF8D86A4);
  static const Color borderDark = Color(0x443F3762);

  // Functional status
  static const Color success = Color(0xFF10B981); // Soothing Green
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Calming Amber
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444); // Gentle Rose Red
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Safety & Crisis Colors (distinct, high clarity, compassionate)
  static const Color safetyRed = Color(0xFFDC2626);
  static const Color safetyBg = Color(0xFFFEF2F2);
  static const Color safetyBorder = Color(0xFFFECACA);
}
