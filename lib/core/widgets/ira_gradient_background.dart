import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_gradients.dart';

class IraGradientBackground extends StatelessWidget {
  final Widget child;

  const IraGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.page : AppGradients.pageLight,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Align(
              alignment: const Alignment(-1.1, -0.9),
              child: _Glow(
                color: isDark
                    ? AppColors.secondary.withValues(alpha: 0.2)
                    : AppColors.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: const Alignment(1.1, 0.75),
              child: _Glow(
                color: isDark
                    ? AppColors.accentBlue.withValues(alpha: 0.12)
                    : AppColors.accentBlue.withValues(alpha: 0.08),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;

  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 110, spreadRadius: 35),
        ],
      ),
    );
  }
}
