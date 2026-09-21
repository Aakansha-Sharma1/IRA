import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavioral Analytics'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  size: 64,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Analytics & Trends',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Backend-computed analytics (mood fluctuation, sleep consistency, stress indicators) will be visualized here without hardcoded fake data.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
