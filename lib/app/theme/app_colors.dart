import 'package:flutter/material.dart';

/// IRA AI Curated Design Tokens
/// Focused on emotional calm, wellness, warmth, and modern minimalism.
/// Non-clinical, premium, and visually soothing in both light and dark modes.
abstract final class AppColors {
  // Brand Primary & Accent (Deep Sage / Calming Emerald Teal)
  static const Color primary = Color(0xFF0F766E); // Rich Teal
  static const Color primaryLight = Color(0xFF14B8A6); // Soft Aqua
  static const Color primaryDark = Color(0xFF115E59); // Deep Emerald
  static const Color primaryContainerLight = Color(0xFFCCFBF1);
  static const Color primaryContainerDark = Color(0xFF134E4A);

  // Secondary Accent (Soft Lavender / Serene Iris)
  static const Color secondary = Color(0xFF6366F1); // Gentle Indigo
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFF4338CA);
  static const Color secondaryContainerLight = Color(0xFFE0E7FF);
  static const Color secondaryContainerDark = Color(0xFF312E81);

  // Tertiary Accent (Warm Peach / Soothing Amber for positive wellness)
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color tertiaryContainerLight = Color(0xFFFEF3C7);
  static const Color tertiaryContainerDark = Color(0xFF78350F);

  // Neutral Scales (Slate & Charcoal)
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral950 = Color(0xFF020617);

  // Light Theme Surfaces
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Theme Surfaces
  static const Color backgroundDark = Color(0xFF0A0F1D);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceVariantDark = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF1F2937);

  // Wellness & Functional Status
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
