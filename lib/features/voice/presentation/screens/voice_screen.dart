import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/voice_connection_controller.dart';
import '../controllers/voice_connection_state.dart';
import '../providers/voice_session_providers.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveVoiceChatScreen();
  }
}

class LiveVoiceChatScreen extends ConsumerStatefulWidget {
  const LiveVoiceChatScreen({super.key});

  @override
  ConsumerState<LiveVoiceChatScreen> createState() => _LiveVoiceChatScreenState();
}

class _LiveVoiceChatScreenState extends ConsumerState<LiveVoiceChatScreen> {
  late final VoiceConnectionController _voiceController;
  bool _disconnectStarted = false;

  @override
  void initState() {
    super.initState();
    _voiceController = ref.read(voiceConnectionControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_voiceController.connect());
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileControllerProvider).profile;
    final voiceState = ref.watch(voiceConnectionControllerProvider);
    final repName = profile?.companionName.trim().isNotEmpty == true
        ? profile!.companionName
        : 'IRA';
    final isConnected = voiceState.status == VoiceConnectionStatus.connected;
    final statusText = switch (voiceState.status) {
      VoiceConnectionStatus.connecting => 'Connecting to $repName',
      VoiceConnectionStatus.connected => 'Connected to $repName',
      VoiceConnectionStatus.disconnected => 'Voice session disconnected',
      VoiceConnectionStatus.disconnecting => 'Ending voice call',
      VoiceConnectionStatus.error => 'Voice session error',
    };
    final isBusy = voiceState.status == VoiceConnectionStatus.connecting ||
        voiceState.status == VoiceConnectionStatus.disconnecting;
    final liveStatus = switch (voiceState.status) {
      VoiceConnectionStatus.connecting => 'Connecting to the voice session.',
      VoiceConnectionStatus.connected => voiceState.microphoneEnabled
          ? 'Microphone is on. Speak naturally and $repName will listen.'
          : 'Microphone is muted. Tap the mic to unmute.',
      VoiceConnectionStatus.disconnected => 'Voice session is disconnected.',
      VoiceConnectionStatus.disconnecting => 'Closing the voice session.',
      VoiceConnectionStatus.error =>
          voiceState.failure?.message ?? 'Unable to start the voice session.',
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0B0618),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('$repName live chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to text chat',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: constraints.maxWidth < 360 ? 140.0 : 170.0,
                    height: constraints.maxWidth < 360 ? 140.0 : 170.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                          theme.colorScheme.secondary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      voiceState.microphoneEnabled
                          ? Icons.mic_rounded
                          : Icons.mic_off_rounded,
                      size: constraints.maxWidth < 360 ? 60 : 72,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF211632),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live status',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          liveStatus,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: voiceState.transcript.isEmpty
                        ? Center(
                            child: Text(
                              'Your conversation will appear here.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: voiceState.transcript.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final line = voiceState.transcript[index];
                              return Align(
                                alignment: line.isAgent
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 320),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: line.isAgent
                                        ? const Color(0xFF211632)
                                        : const Color(0xFF7B3FE4),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    line.text,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isConnected && !isBusy
                              ? () {
                                  final controller = ref.read(
                                    voiceConnectionControllerProvider.notifier,
                                  );
                                  unawaited(
                                    voiceState.microphoneEnabled
                                        ? controller.muteMicrophone()
                                        : controller.unmuteMicrophone(),
                                  );
                                }
                              : null,
                          icon: Icon(
                            voiceState.microphoneEnabled
                                ? Icons.mic_off_rounded
                                : Icons.mic_rounded,
                          ),
                          label: Text(
                            voiceState.microphoneEnabled ? 'Mute mic' : 'Unmute mic',
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
                            backgroundColor: const Color(0xFFE0526B),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
