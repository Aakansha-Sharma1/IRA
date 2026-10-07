import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_icon_container.dart';
import '../../../../core/widgets/ira_section_header.dart';
import 'breathing_exercise_screen.dart';

class BreathingExercise {
  final String name;
  final String description;
  final String duration;
  final String pattern;
  final String intensity;
  final List<BreathingPhase> phases;

  const BreathingExercise({
    required this.name,
    required this.description,
    required this.duration,
    required this.pattern,
    required this.intensity,
    required this.phases,
  });
}

class BreathingPhase {
  final String label;
  final int seconds;
  final bool expands;

  const BreathingPhase(this.label, this.seconds, {this.expands = false});
}

const breathingExercises = [
  BreathingExercise(
    name: 'Box Breathing',
    description: 'A steady rhythm to settle a busy mind and release tension.',
    duration: '1 min',
    pattern: 'Inhale 4 · Hold 4 · Exhale 4 · Hold 4',
    intensity: 'Beginner',
    phases: [
      BreathingPhase('Breathe In', 4, expands: true),
      BreathingPhase('Hold', 4, expands: true),
      BreathingPhase('Breathe Out', 4),
      BreathingPhase('Hold', 4),
    ],
  ),
  BreathingExercise(
    name: '4-7-8 Relaxation',
    description: 'A longer exhale to help your body shift toward calm.',
    duration: '1 min',
    pattern: 'Inhale 4 · Hold 7 · Exhale 8',
    intensity: 'Gentle',
    phases: [
      BreathingPhase('Breathe In', 4, expands: true),
      BreathingPhase('Hold', 7, expands: true),
      BreathingPhase('Breathe Out', 8),
    ],
  ),
  BreathingExercise(
    name: 'Calm Breathing',
    description: 'A simple, soothing rhythm for a quiet mindful pause.',
    duration: '1 min',
    pattern: 'Inhale 4 · Exhale 6',
    intensity: 'Beginner',
    phases: [
      BreathingPhase('Breathe In', 4, expands: true),
      BreathingPhase('Breathe Out', 6),
    ],
  ),
  BreathingExercise(
    name: 'Quick Stress Reset',
    description:
        'A short guided pattern for moments when you need to slow down.',
    duration: '30 sec',
    pattern: 'Inhale 3 · Exhale 5',
    intensity: 'Quick',
    phases: [
      BreathingPhase('Breathe In', 3, expands: true),
      BreathingPhase('Breathe Out', 5),
    ],
  ),
];

class WellnessDashboardScreen extends StatelessWidget {
  const WellnessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Wellness'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Home',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: AppDimensions.screenPadding,
        children: [
          Text(
            'Find a calmer moment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'These short breathing exercises can help ease stress, release tension, and make space to relax.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.space24),
          const IraSectionHeader(
            title: 'BREATHING EXERCISES',
            subtitle: 'Choose a pace that feels comfortable',
          ),
          const SizedBox(height: AppDimensions.space8),
          ...breathingExercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space12),
              child: IraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const IraIconContainer(
                          icon: Icons.air_rounded,
                          size: 48,
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Text(exercise.description),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      '${exercise.duration} · ${exercise.intensity}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    Text(
                      exercise.pattern,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.space12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => BreathingExerciseScreen(
                              exercise: exercise,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
