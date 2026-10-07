import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_dimensions.dart';
import 'wellness_dashboard_screen.dart';

class BreathingExerciseScreen extends StatefulWidget {
  final BreathingExercise exercise;

  const BreathingExerciseScreen({super.key, required this.exercise});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  Timer? _timer;
  var _phaseIndex = 0;
  var _remainingSeconds = 0;
  var _completedCycles = 0;
  var _isPaused = false;
  var _isComplete = false;

  BreathingPhase get _phase => widget.exercise.phases[_phaseIndex];
  int get _cycleDuration =>
      widget.exercise.phases.fold(0, (sum, phase) => sum + phase.seconds);
  int get _totalSeconds => _cycleDuration * 3;
  int get _elapsedSeconds =>
      (_completedCycles * _cycleDuration) +
      widget.exercise.phases
          .take(_phaseIndex)
          .fold<int>(0, (sum, phase) => sum + phase.seconds) +
      (_phase.seconds - _remainingSeconds);

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _phase.seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_isPaused || _isComplete) return;
    if (_remainingSeconds > 1) {
      setState(() => _remainingSeconds--);
      return;
    }

    final nextPhase = _phaseIndex + 1;
    if (nextPhase < widget.exercise.phases.length) {
      setState(() {
        _phaseIndex = nextPhase;
        _remainingSeconds = _phase.seconds;
      });
      return;
    }

    if (_completedCycles == 2) {
      setState(() => _isComplete = true);
      _timer?.cancel();
      return;
    }

    setState(() {
      _completedCycles++;
      _phaseIndex = 0;
      _remainingSeconds = widget.exercise.phases.first.seconds;
    });
  }

  void _endSession() {
    _timer?.cancel();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Home',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: _isComplete
              ? _CompletionView(onDone: () => Navigator.pop(context))
              : Column(
                  children: [
                    Text(
                      'Follow your natural pace',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      widget.exercise.pattern,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.space32),
                    Expanded(
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeInOut,
                          width: _phase.expands ? 220 : 156,
                          height: _phase.expands ? 220 : 156,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5B7CFA), Color(0xFFB06CDE)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.25),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _phase.label,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space8),
                              Text(
                                '$_remainingSeconds',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    LinearProgressIndicator(
                      value: _totalSeconds == 0
                          ? 0
                          : _elapsedSeconds / _totalSeconds,
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Cycle ${_completedCycles + 1} of 3',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.space16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _isPaused = !_isPaused),
                          icon: Icon(
                            _isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          label: Text(_isPaused ? 'Resume' : 'Pause'),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        TextButton(
                          onPressed: _endSession,
                          child: const Text('End'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  final VoidCallback onDone;

  const _CompletionView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 72),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'Breathing complete',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.space8),
          const Text('Take a moment to notice how you feel.'),
          const SizedBox(height: AppDimensions.space24),
          FilledButton(onPressed: onDone, child: const Text('Done')),
        ],
      ),
    );
  }
}
