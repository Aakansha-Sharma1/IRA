import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_button.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.space24),
              Text(
                'Personalize Your Wellness Companion',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space12),
              Text(
                'IRA learns your wellness rhythms to offer preventive guidance and gentle reflections.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space32),
              Expanded(
                child: ListView(
                  children: const [
                    IraCard(
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 32),
                          SizedBox(width: AppDimensions.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Supportive Conversations',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Express how you feel via text or voice in a safe, non-judgmental space.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.space16),
                    IraCard(
                      child: Row(
                        children: [
                          Icon(Icons.insights_rounded, size: 32),
                          SizedBox(width: AppDimensions.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Behavioral Patterns & Insights',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Understand mood, sleep, stress, and lifestyle trends over time.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.space16),
                    IraCard(
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 32),
                          SizedBox(width: AppDimensions.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Safety & Privacy First',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Not a medical diagnosis tool. Sensitive data stays encrypted and private.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IraButton(
                text: 'Get Started',
                onPressed: () {
                  ref.read(authControllerProvider.notifier).completeOnboarding();
                },
              ),
              const SizedBox(height: AppDimensions.space16),
            ],
          ),
        ),
      ),
    );
  }
}
