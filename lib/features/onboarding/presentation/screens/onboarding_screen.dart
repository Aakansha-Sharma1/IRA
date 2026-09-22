import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_button.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_text_field.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;

  // Step 2: Basic Profile controllers & state
  final _displayNameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Prefer not to say';
  String _selectedTimezone = 'UTC';
  final _formKey = GlobalKey<FormState>();

  // Step 3: Lifestyle Context state
  final Set<String> _selectedGoals = {'Stress Management', 'Sleep Quality'};
  double _sleepHoursTarget = 8.0;
  String _activityLevel = 'Moderate';

  final List<String> _availableGoals = [
    'Stress Management',
    'Sleep Quality',
    'Mindfulness & Focus',
    'Physical Energy',
    'Emotional Balance',
  ];

  final List<String> _genderOptions = [
    'Prefer not to say',
    'Female',
    'Male',
    'Non-binary',
  ];

  final List<String> _activityLevels = [
    'Sedentary',
    'Moderate',
    'Active',
  ];

  final List<String> _commonTimezones = [
    'UTC',
    'America/New_York',
    'America/Los_Angeles',
    'America/Chicago',
    'Europe/London',
    'Europe/Paris',
    'Asia/Kolkata',
    'Asia/Tokyo',
    'Australia/Sydney',
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) return;
    }
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _submitOnboarding() async {
    final age = int.tryParse(_ageController.text.trim());
    final success =
        await ref.read(profileControllerProvider.notifier).createProfile(
              displayName: _displayNameController.text.trim(),
              age: age,
              gender: _selectedGender == 'Prefer not to say'
                  ? null
                  : _selectedGender,
              timezone: _selectedTimezone,
              wellnessGoals: _selectedGoals.toList(),
              sleepHoursTarget: _sleepHoursTarget,
              activityLevel: _activityLevel.toLowerCase(),
            );

    if (!success && mounted) {
      final state = ref.read(profileControllerProvider);
      final errorMsg = state.failure?.message ?? 'Failed to complete onboarding.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final isSaving = profileState.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IRA Setup'),
        centerTitle: true,
        leading: _currentStep > 0 && !isSaving
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentStep + 1} of 4',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getStepTitle(_currentStep),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppDimensions.screenPadding,
                child: _buildCurrentStep(theme, isSaving),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Welcome';
      case 1:
        return 'Personal Info';
      case 2:
        return 'Lifestyle Context';
      case 3:
        return 'Review & Confirm';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep(ThemeData theme, bool isSaving) {
    switch (_currentStep) {
      case 0:
        return _buildStepWelcome(theme);
      case 1:
        return _buildStepBasicProfile(theme);
      case 2:
        return _buildStepLifestyleContext(theme);
      case 3:
        return _buildStepReview(theme, isSaving);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEP 1: WELCOME & PURPOSE ---
  Widget _buildStepWelcome(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppDimensions.space16),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.spa_rounded,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.space24),
        Text(
          'Welcome to IRA',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          'Your Intelligent Responsive Companion for Daily Lifestyle & Behavioral Wellness.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),
        const IraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
                  SizedBox(width: AppDimensions.space12),
                  Text(
                    'Preventive Wellness Companion',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'IRA helps you recognize stress patterns, track lifestyle rhythms, and build sustainable wellness habits through supportive conversations.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space16),
        IraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      color: theme.colorScheme.primary),
                  const SizedBox(width: AppDimensions.space12),
                  const Text(
                    'Clear Safety Boundary',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'IRA is strictly a lifestyle companion, NOT a medical diagnostic tool or clinical treatment system. Your personal data is confidential and secure.',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space32),
        IraButton(
          text: 'Get Started',
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // --- STEP 2: BASIC PROFILE ---
  Widget _buildStepBasicProfile(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Personal Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Tell us how to address you and your local time context.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.space24),
          IraTextField(
            controller: _displayNameController,
            label: 'Display Name',
            hintText: 'e.g. Aakansha or Alex',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your display name';
              }
              if (v.trim().length > 100) {
                return 'Display name cannot exceed 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.space16),
          IraTextField(
            controller: _ageController,
            label: 'Age',
            hintText: 'e.g. 24 (Optional, 13–120)',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.cake_outlined),
            validator: (v) {
              if (v != null && v.trim().isNotEmpty) {
                final parsed = int.tryParse(v.trim());
                if (parsed == null || parsed < 13 || parsed > 120) {
                  return 'Please enter a valid age between 13 and 120';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.space16),
          // Gender Selection
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Gender (Optional)',
              prefixIcon: const Icon(Icons.diversity_3_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGender,
                isDense: true,
                items: _genderOptions.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedGender = v);
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          // Timezone selection
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'Timezone',
              prefixIcon: const Icon(Icons.public_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTimezone,
                isDense: true,
                items: _commonTimezones.map((tz) {
                  return DropdownMenuItem(value: tz, child: Text(tz));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedTimezone = v);
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          IraButton(
            text: 'Continue',
            onPressed: _nextStep,
          ),
        ],
      ),
    );
  }

  // --- STEP 3: LIFESTYLE CONTEXT ---
  Widget _buildStepLifestyleContext(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lifestyle & Wellness Priorities',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          'Select your primary areas of focus for tailored reflections.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppDimensions.space24),
        Text(
          'Wellness Goals',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.space8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableGoals.map((goal) {
            final isSelected = _selectedGoals.contains(goal);
            return FilterChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGoals.add(goal);
                  } else {
                    _selectedGoals.remove(goal);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.space24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target Sleep Hours',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_sleepHoursTarget.toStringAsFixed(1)} hrs / night',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Slider(
          value: _sleepHoursTarget,
          min: 4.0,
          max: 12.0,
          divisions: 16,
          label: '${_sleepHoursTarget.toStringAsFixed(1)} hrs',
          onChanged: (v) {
            setState(() => _sleepHoursTarget = v);
          },
        ),
        const SizedBox(height: AppDimensions.space16),
        Text(
          'Daily Activity Level',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.space8),
        SegmentedButton<String>(
          segments: _activityLevels.map((lvl) {
            return ButtonSegment<String>(value: lvl, label: Text(lvl));
          }).toList(),
          selected: {_activityLevel},
          onSelectionChanged: (set) {
            setState(() => _activityLevel = set.first);
          },
        ),
        const SizedBox(height: AppDimensions.space32),
        IraButton(
          text: 'Review & Complete',
          onPressed: _nextStep,
        ),
      ],
    );
  }

  // --- STEP 4: REVIEW & CONFIRM ---
  Widget _buildStepReview(ThemeData theme, bool isSaving) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Confirm Your Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          'Please verify your details. This information will be securely persisted to PostgreSQL.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppDimensions.space24),
        IraCard(
          child: Column(
            children: [
              _buildReviewRow('Display Name', _displayNameController.text),
              const Divider(),
              _buildReviewRow(
                'Age',
                _ageController.text.trim().isNotEmpty
                    ? _ageController.text.trim()
                    : 'Not specified',
              ),
              const Divider(),
              _buildReviewRow('Gender', _selectedGender),
              const Divider(),
              _buildReviewRow('Timezone', _selectedTimezone),
              const Divider(),
              _buildReviewRow(
                'Wellness Goals',
                _selectedGoals.isEmpty
                    ? 'None selected'
                    : _selectedGoals.join(', '),
              ),
              const Divider(),
              _buildReviewRow(
                'Target Sleep',
                '${_sleepHoursTarget.toStringAsFixed(1)} hrs',
              ),
              const Divider(),
              _buildReviewRow('Activity Level', _activityLevel),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space32),
        IraButton(
          text: isSaving ? 'Saving to Database...' : 'Complete Setup',
          isLoading: isSaving,
          onPressed: isSaving ? null : _submitOnboarding,
        ),
        const SizedBox(height: AppDimensions.space16),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
