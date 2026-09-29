import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

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
  bool _isListening = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileControllerProvider).profile;
    final repName = profile?.companionName.trim().isNotEmpty == true
        ? profile!.companionName
        : 'IRA';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
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
                      _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                      size: constraints.maxWidth < 360 ? 60 : 72,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isListening ? 'Listening for $repName' : 'Voice paused',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live status',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isListening
                              ? 'Microphone active. Speak naturally and $repName will listen for your next input.'
                              : 'Microphone paused. Tap the mic again to resume listening.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _isListening = !_isListening),
                          icon: Icon(
                            _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                          ),
                          label: Text(_isListening ? 'Mute mic' : 'Resume mic'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Back to chat'),
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
