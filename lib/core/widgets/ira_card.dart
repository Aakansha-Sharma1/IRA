import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

/// Standard card with customizable elevation, padding, and tap handler
class IraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;

  const IraCard({
    super.key,
    required this.child,
    this.padding = AppDimensions.cardPadding,
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      side: border ??
          BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
    );

    return Card(
      color: backgroundColor ?? theme.cardTheme.color,
      elevation: theme.cardTheme.elevation,
      shape: cardShape,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
