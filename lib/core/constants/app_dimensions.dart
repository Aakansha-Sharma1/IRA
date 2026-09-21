import 'package:flutter/widgets.dart';

/// Standardized layout dimensions, spacing tokens, and border radii.
abstract final class AppDimensions {
  // Spacing
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Component Sizes
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;
  static const double inputHeight = 52.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Touch Target Minimum
  static const double minTouchTarget = 48.0;

  // Standard Edge Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: space20,
    vertical: space16,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(space16);
  static const EdgeInsets dialogPadding = EdgeInsets.all(space24);
}
