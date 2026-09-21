import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Emotion Logging'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sentiment_satisfied_alt_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'Daily Mood Logging',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'This module will communicate with the backend MoodService to record and analyze emotional states.',
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
