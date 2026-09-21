import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 64,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Preventive Guidance & Insights',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Backend-generated wellness correlations and gentle lifestyle reflections will populate here.',
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
