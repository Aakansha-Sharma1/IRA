import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/ira_button.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final List<String> _genderOptions = ['Female', 'Male', 'Non-binary'];
  final List<String> _ageOptions = [
    'Under 18',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65 and over',
  ];
  final List<String> _pronounOptions = ['She / Her', 'He / Him', 'They / Them'];
  final List<String> _goalOptions = [
    'Someone special',
    'A friend who listens and cares',
    'Someone to support my mental well-being',
    'A coach to help me reach my goals',
    'An English tutor to practice with',
    'Something else',
  ];

  final TextEditingController _repNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  int _currentStep = 0;
  String _selectedGender = 'Female';
  String _selectedAge = '18-24';
  String _selectedPronoun = 'She / Her';
  String _selectedGoal = 'Someone special';

  @override
  void dispose() {
    _repNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String _companionNameValue() {
    final candidate = _repNameController.text.trim();
    return candidate.isNotEmpty ? candidate : 'IRA';
  }

  Future<void> _submitOnboarding() async {
    final displayName = [
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((value) => value.isNotEmpty).join(' ');

    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name to continue.'),
        ),
      );
      return;
    }

    final ageValue = _selectedAge == 'Under 18'
        ? 17
        : _selectedAge == '18-24'
            ? 22
            : _selectedAge == '25-34'
                ? 30
                : _selectedAge == '35-44'
                    ? 40
                    : _selectedAge == '45-54'
                        ? 50
                        : _selectedAge == '55-64'
                            ? 60
                            : 70;

    final success =
        await ref.read(profileControllerProvider.notifier).createProfile(
              displayName: displayName,
              companionName: _companionNameValue(),
              age: ageValue,
              gender: _selectedGender,
              pronouns: _selectedPronoun,
              timezone: 'UTC',
              wellnessGoals: [_selectedGoal],
              sleepHoursTarget: 8.0,
              activityLevel: 'moderate',
            );

    if (!success && mounted) {
      final state = ref.read(profileControllerProvider);
      final errorMsg =
          state.failure?.message ?? 'Failed to complete onboarding.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
      return;
    }

    _submitOnboarding();
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Widget _buildStepBody() {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileControllerProvider);

    if (profileState.isSaving) {
      final companionName = _companionNameValue();
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "We're creating\n$companionName for you",
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 180,
                child: LinearProgressIndicator(minHeight: 8),
              ),
              const SizedBox(height: 18),
              Text(
                'This can take up to 2 minutes.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentStep) {
      case 0:
        return _buildUserNameStep();
      case 1:
        return _buildPronounsStep();
      case 2:
        return _buildAgeStep();
      case 3:
        return _buildCompanionNameStep();
      case 4:
        return _buildGenderStep();
      case 5:
        return _buildGoalStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'What gender would you like\nyour companion to be?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2333),
                ),
          ),
          const SizedBox(height: 40),
          ..._genderOptions.map((gender) {
            final selected = _selectedGender == gender;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedGender = gender);
                  _nextStep();
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    gender,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1E2333),
                        ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAgeStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'How old are you?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2333),
                ),
          ),
          const SizedBox(height: 40),
          ..._ageOptions.map((age) {
            final selected = _selectedAge == age;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedAge = age);
                  _nextStep();
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(40),
                    border: selected
                        ? Border.all(color: const Color(0xFF4F7FFF), width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    age,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1E2333),
                        ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPronounsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Which pronouns do you use?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2333),
                ),
          ),
          const SizedBox(height: 30),
          ..._pronounOptions.map((pronoun) {
            final selected = _selectedPronoun == pronoun;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedPronoun = pronoun);
                  _nextStep();
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(40),
                    border: selected
                        ? Border.all(color: const Color(0xFF4F7FFF), width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    pronoun,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1E2333),
                        ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUserNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Hey!\nWhat's your name?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2333),
                ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _firstNameController,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Your name',
                filled: true,
                fillColor: const Color(0xFFEAEAEA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _lastNameController,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Last name',
                filled: true,
                fillColor: const Color(0xFFEAEAEA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 280,
            child: IraButton(
              text: 'Continue',
              onPressed: _nextStep,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompanionNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "What's your companion's name?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2333),
                ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: _repNameController,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Your companion name',
                filled: true,
                fillColor: const Color(0xFFEAEAEA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
              ),
              onSubmitted: (_) => _nextStep(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 280,
            child: IraButton(
              text: 'Continue',
              onPressed: _nextStep,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'What are you looking for?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2333),
                ),
          ),
          const SizedBox(height: 40),
          ..._goalOptions.map((goal) {
            final selected = _selectedGoal == goal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedGoal = goal);
                  _nextStep();
                },
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(40),
                    border: selected
                        ? Border.all(color: const Color(0xFF4F7FFF), width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    goal,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1E2333),
                        ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isSaving = profileState.isSaving;

    return Scaffold(
      backgroundColor:
          isSaving ? const Color(0xFF3D7BFF) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: isSaving
            ? _buildStepBody()
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SizedBox(
                  key: ValueKey<int>(_currentStep),
                  child: _buildStepBody(),
                ),
              ),
      ),
    );
  }
}
