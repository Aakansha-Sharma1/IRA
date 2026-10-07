import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/ira_card.dart';
import '../../../../core/widgets/ira_gradient_background.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/voice_connection_controller.dart';
import '../controllers/voice_connection_state.dart';
import '../providers/voice_session_providers.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) => const LiveVoiceChatScreen();
}

class LiveVoiceChatScreen extends ConsumerStatefulWidget {
  const LiveVoiceChatScreen({super.key});

  @override
  ConsumerState<LiveVoiceChatScreen> createState() =>
      _LiveVoiceChatScreenState();
}

class _LiveVoiceChatScreenState extends ConsumerState<LiveVoiceChatScreen>
    with SingleTickerProviderStateMixin {
  late final VoiceConnectionController _voiceController;
  late final AnimationController _waveController;
  Timer? _iraSpeakingTimer;
  bool _disconnectStarted = false;
  bool _iraSpeaking = false;

  @override
  void initState() {
    super.initState();
    _voiceController = ref.read(voiceConnectionControllerProvider.notifier);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_voiceController.connect());
    });
  }

  @override
  void dispose() {
    _iraSpeakingTimer?.cancel();
    _waveController.dispose();
    if (!_disconnectStarted) {
      _disconnectStarted = true;
      unawaited(_voiceController.disconnect(notifyState: false));
    }
    super.dispose();
  }

  Future<void> _endCall() async {
    if (_disconnectStarted) return;
    _disconnectStarted = true;
    await _voiceController.disconnect();
    if (mounted) context.pop();
  }

  void _markIraSpeaking() {
    if (!mounted) return;
    _iraSpeakingTimer?.cancel();
    setState(() => _iraSpeaking = true);
    _iraSpeakingTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _iraSpeaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VoiceConnectionState>(
      voiceConnectionControllerProvider,
      (previous, next) {
        final previousTranscript = previous?.transcript;
        final latest = next.transcript.isEmpty ? null : next.transcript.last;
        final receivedNewAgentLine = latest != null &&
            latest.isAgent &&
            (previousTranscript == null ||
                previousTranscript.isEmpty ||
                previousTranscript.last.id != latest.id ||
                previousTranscript.last.text != latest.text);
        if (receivedNewAgentLine) _markIraSpeaking();
      },
    );

    final theme = Theme.of(context);
    final profile = ref.watch(profileControllerProvider).profile;
    final voiceState = ref.watch(voiceConnectionControllerProvider);
    final repName = profile?.companionName.trim().isNotEmpty == true
        ? profile!.companionName
        : 'IRA';
    final isConnected = voiceState.status == VoiceConnectionStatus.connected;
    final isBusy = voiceState.status == VoiceConnectionStatus.connecting ||
        voiceState.status == VoiceConnectionStatus.disconnecting;
    final stateLabel = _stateLabel(voiceState, repName);
    final stateDescription = _stateDescription(voiceState, repName);

    return Scaffold(
      appBar: AppBar(
        title: Text('$repName live chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to text chat',
          onPressed: () => context.pop(),
        ),
      ),
      body: IraGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.screenPadding,
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.space12),
                Text(
                  'Voice chat with $repName',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  stateLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _stateColor(voiceState, theme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  stateDescription,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.space20),
                _VoiceWaveform(
                  controller: _waveController,
                  active: _iraSpeaking || isConnected,
                  speaking: _iraSpeaking,
                ),
                const SizedBox(height: AppDimensions.space20),
                IraCard(
                  child: Row(
                    children: [
                      Icon(
                        _iraSpeaking
                            ? Icons.graphic_eq_rounded
                            : voiceState.microphoneEnabled
                                ? Icons.hearing_rounded
                                : Icons.mic_off_rounded,
                        color: _iraSpeaking
                            ? AppColors.secondaryDark
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Text(
                          _iraSpeaking
                              ? '$repName is responding'
                              : voiceState.microphoneEnabled
                                  ? 'Listening for your voice'
                                  : 'Microphone is off',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                Expanded(
                  child: voiceState.transcript.isEmpty
                      ? Center(
                          child: Text(
                            'Your conversation will appear here.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: voiceState.transcript.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final line = voiceState.transcript[index];
                            return Align(
                              alignment: line.isAgent
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: IraCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                backgroundColor: line.isAgent
                                    ? null
                                    : theme.colorScheme.primaryContainer,
                                child: Text(line.text),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: AppDimensions.space12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isConnected && !isBusy
                            ? () {
                                unawaited(
                                  voiceState.microphoneEnabled
                                      ? _voiceController.muteMicrophone()
                                      : _voiceController.unmuteMicrophone(),
                                );
                              }
                            : null,
                        icon: Icon(
                          voiceState.microphoneEnabled
                              ? Icons.mic_off_rounded
                              : Icons.mic_rounded,
                        ),
                        label: Text(
                          voiceState.microphoneEnabled
                              ? 'Mute mic'
                              : 'Unmute mic',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isBusy ? null : _endCall,
                        icon: const Icon(Icons.call_end_rounded),
                        label: const Text('End call'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _stateLabel(VoiceConnectionState state, String repName) {
    if (_iraSpeaking) return '$repName is speaking';
    return switch (state.status) {
      VoiceConnectionStatus.connecting => 'Connecting',
      VoiceConnectionStatus.connected =>
        state.microphoneEnabled ? 'Listening' : 'Microphone off',
      VoiceConnectionStatus.disconnected => 'Disconnected',
      VoiceConnectionStatus.disconnecting => 'Ending conversation',
      VoiceConnectionStatus.error => 'Could not connect',
    };
  }

  String _stateDescription(VoiceConnectionState state, String repName) {
    return switch (state.status) {
      VoiceConnectionStatus.connecting => 'Getting your voice space ready.',
      VoiceConnectionStatus.connected => state.microphoneEnabled
          ? 'Speak naturally and $repName will listen.'
          : 'Turn on your microphone when you are ready.',
      VoiceConnectionStatus.disconnected =>
        'The voice session is disconnected.',
      VoiceConnectionStatus.disconnecting => 'Closing the voice session.',
      VoiceConnectionStatus.error =>
        state.failure?.message ?? 'Please try connecting again.',
    };
  }

  Color _stateColor(VoiceConnectionState state, ThemeData theme) {
    if (_iraSpeaking) return AppColors.secondaryDark;
    return switch (state.status) {
      VoiceConnectionStatus.error => theme.colorScheme.error,
      VoiceConnectionStatus.connected => AppColors.success,
      _ => theme.colorScheme.primary,
    };
  }
}

class _VoiceWaveform extends StatelessWidget {
  final Animation<double> controller;
  final bool active;
  final bool speaking;

  const _VoiceWaveform({
    required this.controller,
    required this.active,
    required this.speaking,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WaveformPainter(
              phase: controller.value,
              active: active,
              speaking: speaking,
              color: Theme.of(context).colorScheme.primary,
              accent: Theme.of(context).colorScheme.secondary,
            ),
            child: child,
          );
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double phase;
  final bool active;
  final bool speaking;
  final Color color;
  final Color accent;

  const _WaveformPainter({
    required this.phase,
    required this.active,
    required this.speaking,
    required this.color,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const heights = [
      0.2,
      0.34,
      0.52,
      0.72,
      0.9,
      0.62,
      0.42,
      0.28,
      0.42,
      0.62,
      0.9,
      0.72,
      0.52,
      0.34,
      0.2
    ];
    final barWidth = size.width / (heights.length * 1.8);
    final gap = barWidth * 0.8;
    final centerY = size.height / 2;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (var index = 0; index < heights.length; index++) {
      final x = (barWidth + gap) * index + barWidth;
      final movement = (0.88 + 0.12 * (index.isEven ? 1 : -1)) *
          (0.9 + 0.1 * ((phase + index / heights.length) % 1));
      final activity = active ? (speaking ? 1.0 : 0.72) : 0.28;
      final barHeight = size.height * heights[index] * activity * movement;
      paint
        ..color = Color.lerp(color, accent, index / heights.length)!
        ..strokeWidth = barWidth;
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.active != active ||
      oldDelegate.speaking != speaking ||
      oldDelegate.color != color ||
      oldDelegate.accent != accent;
}
