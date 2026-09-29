import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_error_view.dart';
import '../../../../core/widgets/ira_loading_indicator.dart';
import '../../domain/entities/mood_entry.dart';
import '../controllers/mood_controller.dart';

class MoodHistoryScreen extends ConsumerStatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  ConsumerState<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends ConsumerState<MoodHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moodControllerProvider.notifier).loadMoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodControllerProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: IraLoadingIndicator(message: 'Loading mood history...'),
      );
    }

    if (state.isError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mood History')),
        body: IraErrorView(
          title: 'Unable to load mood history',
          message: state.failure?.message ?? 'Please try again.',
          onRetry: () => ref.read(moodControllerProvider.notifier).loadMoods(),
        ),
      );
    }

    final entries = state.entries;
    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mood History')),
        body: Center(
          child: Padding(
            padding: AppDimensions.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mood_bad_outlined, size: 48),
                const SizedBox(height: AppDimensions.space12),
                Text(
                  'No mood entries yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Your recorded daily check-ins will appear here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.dailyCheckIn),
            icon: const Icon(Icons.add_reaction_outlined),
            tooltip: 'New check-in',
          ),
        ],
      ),
      body: ListView.separated(
        padding: AppDimensions.screenPadding,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.space12),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return IraCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${entry.entryDate.day}/${entry.entryDate.month}/${entry.entryDate.year}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Chip(label: Text(entry.mood.label)),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Text('Intensity: ${entry.intensity}/5'),
                if ((entry.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.space8),
                  Text(entry.note ?? ''),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
