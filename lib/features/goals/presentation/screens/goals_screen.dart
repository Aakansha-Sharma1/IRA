import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Goals'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Habits & Wellness Goals',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Track sleep, exercise, and hydration habits connected directly to backend endpoints.',
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
