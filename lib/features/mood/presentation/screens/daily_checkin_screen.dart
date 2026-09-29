import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_button.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_error_view.dart';
import '../../../../core/widgets/ira_loading_indicator.dart';
import '../../domain/entities/mood_entry.dart';
import '../controllers/mood_controller.dart';

class DailyCheckInScreen extends ConsumerStatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  ConsumerState<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends ConsumerState<DailyCheckInScreen> {
  MoodValue _selectedMood = MoodValue.good;
  int _selectedIntensity = 3;
  final TextEditingController _noteController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeFromExistingMood();
  }

  void _initializeFromExistingMood() {
    final moodState = ref.read(moodControllerProvider);
    final today = moodState.todayEntry;
    if (today != null) {
      _selectedMood = today.mood;
      _selectedIntensity = today.intensity;
      _noteController.text = today.note ?? '';
      _isEditing = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodControllerProvider);
    final todayEntry = moodState.todayEntry;
    final isSaving = moodState.isSaving;

    if (moodState.isLoading) {
      return const Scaffold(
        body: IraLoadingIndicator(message: 'Loading today\'s check-in...'),
      );
    }

    if (moodState.isError && todayEntry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daily Check-In')),
        body: IraErrorView(
          title: 'Unable to load today\'s mood',
          message: moodState.failure?.message ?? 'Please try again.',
          onRetry: () => ref.read(moodControllerProvider.notifier).loadMoods(),
        ),
      );
    }

    const moodOptions = MoodValue.values;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-In'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.moodHistory),
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Mood history',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppDimensions.screenPadding,
          children: [
            Text(
              _isEditing ? 'Update today\'s check-in' : 'How are you feeling today?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppDimensions.space16),
            IraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mood', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDimensions.space12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: moodOptions.map((mood) {
                      final selected = _selectedMood == mood;
                      return ChoiceChip(
                        label: Text(mood.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedMood = mood),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            IraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Intensity', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      final selected = value == _selectedIntensity;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text('$value'),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedIntensity = value),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            IraCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Note (optional)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDimensions.space12),
                  TextField(
                    controller: _noteController,
                    maxLength: 280,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'What shaped your mood today?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            IraButton(
              text: isSaving ? 'Saving...' : (_isEditing ? 'Update check-in' : 'Save check-in'),
              isLoading: isSaving,
              onPressed: isSaving ? null : _submit,
            ),
            if (moodState.failure != null) ...[
              const SizedBox(height: AppDimensions.space12),
              Text(
                moodState.failure!.message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final saved = await ref.read(moodControllerProvider.notifier).saveMood(
      mood: _selectedMood,
      intensity: _selectedIntensity,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      entryDate: DateTime.now(),
      moodId: _isEditing ? ref.read(moodControllerProvider).todayEntry?.id : null,
    );

    if (!mounted) return;
    if (saved != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood check-in saved.')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
