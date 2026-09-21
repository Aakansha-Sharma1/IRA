import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';

enum IraButtonVariant { primary, secondary, outlined, text }

/// Standard reusable IRA button with loading and disabled states
class IraButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IraButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;

  const IraButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = IraButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeightMd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = !isLoading && onPressed != null;

    final child = isLoading
        ? SizedBox(
            height: AppDimensions.iconSm,
            width: AppDimensions.iconSm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == IraButtonVariant.outlined || variant == IraButtonVariant.text
                    ? theme.colorScheme.primary
                    : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppDimensions.space8),
              ],
              Text(text),
            ],
          );

    final buttonStyle = switch (variant) {
      IraButtonVariant.primary => ElevatedButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height),
        ),
      IraButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          minimumSize: Size(width ?? double.infinity, height),
        ),
      IraButtonVariant.outlined => OutlinedButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height),
        ),
      IraButtonVariant.text => TextButton.styleFrom(
          minimumSize: Size(width ?? 0, height),
        ),
    };

    return switch (variant) {
      IraButtonVariant.primary || IraButtonVariant.secondary => ElevatedButton(
          style: buttonStyle,
          onPressed: isInteractive ? onPressed : null,
          child: child,
        ),
      IraButtonVariant.outlined => OutlinedButton(
          style: buttonStyle,
          onPressed: isInteractive ? onPressed : null,
          child: child,
        ),
      IraButtonVariant.text => TextButton(
          style: buttonStyle,
          onPressed: isInteractive ? onPressed : null,
          child: child,
        ),
    };
  }
}
