import 'package:flutter/material.dart';

import '../../app/theme/app_gradients.dart';
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

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: backgroundColor == null ? null : AppGradients.blueViolet,
        color: backgroundColor ??
            theme.colorScheme.surface.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.72 : 0.82,
            ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.fromBorderSide(cardShape.side),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.16 : 0.06,
            ),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
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
