import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_button.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _displayNameController;
  late TextEditingController _ageController;
  String _selectedGender = 'Prefer not to say';
  double _sleepHoursTarget = 8.0;
  String _activityLevel = 'Moderate';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    _displayNameController =
        TextEditingController(text: profile?.displayName ?? '');
    _ageController =
        TextEditingController(text: profile?.age?.toString() ?? '');
    _selectedGender = profile?.gender ?? 'Prefer not to say';
    _sleepHoursTarget = profile?.sleepHoursTarget ?? 8.0;
    _activityLevel = (profile?.activityLevel != null &&
            profile!.activityLevel!.isNotEmpty)
        ? profile.activityLevel![0].toUpperCase() +
            profile.activityLevel!.substring(1)
        : 'Moderate';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _syncControllersWithProfile() {
    final profile = ref.read(profileControllerProvider).profile;
    if (profile != null) {
      _displayNameController.text = profile.displayName;
      _ageController.text = profile.age?.toString() ?? '';
      _selectedGender = profile.gender ?? 'Prefer not to say';
      _sleepHoursTarget = profile.sleepHoursTarget ?? 8.0;
      _activityLevel = (profile.activityLevel != null &&
              profile.activityLevel!.isNotEmpty)
          ? profile.activityLevel![0].toUpperCase() +
              profile.activityLevel!.substring(1)
          : 'Moderate';
    }
  }

  Future<void> _saveProfileChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final age = int.tryParse(_ageController.text.trim());
    final success =
        await ref.read(profileControllerProvider.notifier).updateProfile(
              displayName: _displayNameController.text.trim(),
              age: age,
              gender: _selectedGender == 'Prefer not to say'
                  ? null
                  : _selectedGender,
              sleepHoursTarget: _sleepHoursTarget,
              activityLevel: _activityLevel.toLowerCase(),
            );

    if (mounted) {
      if (success) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully in PostgreSQL!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final failure = ref.read(profileControllerProvider).failure;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure?.message ?? 'Failed to update profile.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final user = authState.user;
    final profile = profileState.profile;
    final isSaving = profileState.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () {
                _syncControllersWithProfile();
                setState(() => _isEditing = true);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Cancel',
              onPressed: () {
                _syncControllersWithProfile();
                setState(() => _isEditing = false);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimensions.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (profile?.displayName.isNotEmpty == true)
                          ? profile!.displayName.substring(0, 1).toUpperCase()
                          : (user != null && user.email.isNotEmpty)
                              ? user.email.substring(0, 1).toUpperCase()
                              : 'U',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                profile?.displayName ?? 'IRA Wellness Member',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'No email associated',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space24),

              if (_isEditing)
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Edit Profile Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      IraTextField(
                        controller: _displayNameController,
                        label: 'Display Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Display name cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      IraTextField(
                        controller: _ageController,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.cake_outlined),
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            final parsed = int.tryParse(v.trim());
                            if (parsed == null || parsed < 13 || parsed > 120) {
                              return 'Age must be between 13 and 120';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Target Sleep Hours:'),
                          Text(
                            '${_sleepHoursTarget.toStringAsFixed(1)} hrs',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Slider(
                        value: _sleepHoursTarget,
                        min: 4.0,
                        max: 12.0,
                        divisions: 16,
                        onChanged: (v) {
                          setState(() => _sleepHoursTarget = v);
                        },
                      ),
                      const SizedBox(height: AppDimensions.space24),
                      IraButton(
                        text: isSaving ? 'Saving Changes...' : 'Save Changes',
                        isLoading: isSaving,
                        onPressed: isSaving ? null : _saveProfileChanges,
                      ),
                      const SizedBox(height: AppDimensions.space12),
                      IraButton(
                        text: 'Cancel',
                        variant: IraButtonVariant.outlined,
                        onPressed: () {
                          _syncControllersWithProfile();
                          setState(() => _isEditing = false);
                        },
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IraCard(
                      child: Column(
                        children: [
                          _buildProfileRow('Display Name', profile?.displayName ?? '—'),
                          const Divider(),
                          _buildProfileRow('Age', profile?.age?.toString() ?? 'Not specified'),
                          const Divider(),
                          _buildProfileRow('Gender', profile?.gender ?? 'Not specified'),
                          const Divider(),
                          _buildProfileRow('Timezone', profile?.timezone ?? 'UTC'),
                          const Divider(),
                          _buildProfileRow(
                            'Target Sleep',
                            profile?.sleepHoursTarget != null
                                ? '${profile!.sleepHoursTarget!.toStringAsFixed(1)} hrs / night'
                                : '8.0 hrs / night',
                          ),
                          const Divider(),
                          _buildProfileRow(
                            'Activity Level',
                            () {
                              final lvl = profile?.activityLevel;
                              if (lvl == null || lvl.isEmpty) return 'Moderate';
                              return lvl[0].toUpperCase() + lvl.substring(1);
                            }(),
                          ),
                          const Divider(),
                          _buildProfileRow(
                            'Onboarding',
                            profile?.onboardingCompleted == true
                                ? 'Completed'
                                : 'Pending',
                          ),
                        ],
                      ),
                    ),
                    if (profile?.wellnessGoals.isNotEmpty == true) ...[
                      const SizedBox(height: AppDimensions.space16),
                      Text(
                        'Focus Areas',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile!.wellnessGoals.map((g) {
                          return Chip(
                            label: Text(g),
                            backgroundColor: theme.colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.space32),
                    IraButton(
                      text: 'Sign Out',
                      variant: IraButtonVariant.outlined,
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).logout();
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
