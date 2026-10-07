import 'package:flutter/material.dart';

import '../../app/theme/app_gradients.dart';
import '../constants/app_dimensions.dart';

class IraIconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient? gradient;

  const IraIconContainer({
    super.key,
    required this.icon,
    this.size = AppDimensions.iconLg + AppDimensions.space16,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? AppGradients.blueViolet,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: Colors.white, size: AppDimensions.iconMd),
      ),
    );
  }
}
