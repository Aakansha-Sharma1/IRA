import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';

class VoiceTranscriptLine extends Equatable {
  final String id;
  final String text;
  final bool isAgent;
  final bool isFinal;

  const VoiceTranscriptLine({
    required this.id,
    required this.text,
    required this.isAgent,
    required this.isFinal,
  });

  @override
  List<Object?> get props => [id, text, isAgent, isFinal];
}

enum VoiceConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VoiceConnectionState extends Equatable {
  final VoiceConnectionStatus status;
  final bool microphoneEnabled;
  final String? roomName;
  final String? participantIdentity;
  final Failure? failure;
  final List<VoiceTranscriptLine> transcript;

  const VoiceConnectionState({
    this.status = VoiceConnectionStatus.disconnected,
    this.microphoneEnabled = false,
    this.roomName,
    this.participantIdentity,
    this.failure,
    this.transcript = const [],
  });

  VoiceConnectionState copyWith({
    VoiceConnectionStatus? status,
    bool? microphoneEnabled,
    String? roomName,
    String? participantIdentity,
    Failure? failure,
    List<VoiceTranscriptLine>? transcript,
    bool clearFailure = false,
    bool clearSession = false,
  }) {
    return VoiceConnectionState(
      status: status ?? this.status,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      roomName: clearSession ? null : (roomName ?? this.roomName),
      participantIdentity:
          clearSession ? null : (participantIdentity ?? this.participantIdentity),
      failure: clearFailure ? null : (failure ?? this.failure),
        transcript: transcript ?? this.transcript,
    );
  }

  bool get isConnected => status == VoiceConnectionStatus.connected;

  @override
  List<Object?> get props => [
        status,
        microphoneEnabled,
        roomName,
        participantIdentity,
        failure,
        transcript,
      ];
}