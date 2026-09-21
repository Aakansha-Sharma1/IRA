import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_card.dart';

/// Dedicated safety & crisis intervention screen.
/// Provides immediate, authoritative access to crisis resources and helplines.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety & Crisis Support'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Compassionate Header Banner
              IraCard(
                backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                border: BorderSide(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: theme.colorScheme.error,
                      size: 36,
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You are not alone',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'IRA is an AI wellness companion, not a crisis service or medical doctor. If you are in distress, support is available.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Text(
                'Immediate Crisis Contacts',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.space12),
              const IraCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.phone_in_talk_rounded, color: Colors.green),
                      title: Text('Tele-MANAS (India 24/7 Helpline)'),
                      subtitle: Text('14416 / 1800 891 4416 (Toll-free)'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone_in_talk_rounded, color: Colors.green),
                      title: Text('Emergency Services'),
                      subtitle: Text('Dial 112 (India National Emergency)'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.public_rounded),
                      title: Text('International Crisis Resources'),
                      subtitle: Text('findahelpline.com (Global confidential support)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              Text(
                'Safety Architectural Principle',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppDimensions.space8),
              IraCard(
                child: Text(
                  'Safety in IRA is backend-authoritative. Conversational turns evaluated as high risk by SafetyService are routed immediately through dedicated safety protocols rather than ordinary conversation.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
