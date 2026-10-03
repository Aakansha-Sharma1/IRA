import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../core/errors/exceptions.dart' as app_errors;
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/voice_session_repository.dart';
import 'voice_connection_state.dart';

class VoiceConnectionController extends StateNotifier<VoiceConnectionState> {
  final VoiceSessionRepository _repository;
  Room? _room;
  EventsListener<RoomEvent>? _roomListener;
  bool _disconnecting = false;

  VoiceConnectionController(this._repository)
      : super(const VoiceConnectionState());

  Future<void> connect() async {
    if (state.status == VoiceConnectionStatus.connecting || state.isConnected) {
      return;
    }

    state = const VoiceConnectionState(status: VoiceConnectionStatus.connecting);
    try {
      AppLogger.info('Requesting voice session from backend.');
      final session = await _repository.createSession();
      AppLogger.info('Voice session details received for room ${session.room}.');
      final room = Room();
      final listener = room.createListener();
      listener.listen(_handleRoomEvent);

      AppLogger.info('Connecting to LiveKit.');
      await room.connect(session.url, session.token);
      AppLogger.info('LiveKit connected.');
      _room = room;
      _roomListener = listener;
      state = VoiceConnectionState(
        status: VoiceConnectionStatus.connected,
        roomName: session.room,
        participantIdentity: session.participantIdentity,
      );

      await _setMicrophoneEnabled(true);
    } catch (error, stackTrace) {
      AppLogger.error('Voice connection failure', error, stackTrace);
      await _cleanupRoom();
      state = VoiceConnectionState(
        status: VoiceConnectionStatus.error,
        failure: _mapFailure(error),
      );
    }
  }

  Future<void> disconnect({bool notifyState = true}) async {
    if (_disconnecting) return;
    _disconnecting = true;

    try {
      await _disconnect(notifyState: notifyState);
    } finally {
      _disconnecting = false;
    }
  }

  Future<void> _disconnect({required bool notifyState}) async {
    final room = _room;
    if (room == null) {
      if (notifyState) state = const VoiceConnectionState();
      return;
    }

    if (notifyState) {
      state = state.copyWith(
        status: VoiceConnectionStatus.disconnecting,
        clearFailure: true,
      );
    }
    AppLogger.info('Disconnecting from LiveKit voice session.');
    try {
      await room.localParticipant?.setMicrophoneEnabled(false);
      await _cleanupRoom();
      if (notifyState) state = const VoiceConnectionState();
    } catch (error, stackTrace) {
      AppLogger.error('Voice disconnect failed', error, stackTrace);
      await _cleanupRoom();
      if (notifyState) {
        state = VoiceConnectionState(
          status: VoiceConnectionStatus.error,
          failure: _mapFailure(error),
        );
      }
    }
  }

  Future<void> muteMicrophone() => _setMicrophoneEnabled(false);

  Future<void> unmuteMicrophone() => _setMicrophoneEnabled(true);

  Future<void> _setMicrophoneEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null || !state.isConnected) return;

    try {
      AppLogger.info(
        enabled ? 'Enabling microphone.' : 'Disabling microphone.',
      );
      await participant.setMicrophoneEnabled(enabled);
      AppLogger.info(
        enabled ? 'Microphone enabled.' : 'Microphone disabled.',
      );
      if (_room?.localParticipant != participant || !state.isConnected) return;
      state = state.copyWith(microphoneEnabled: enabled, clearFailure: true);
    } catch (error, stackTrace) {
      AppLogger.error('Microphone update failed', error, stackTrace);
      if (_room?.localParticipant != participant) return;
      state = state.copyWith(
        status: VoiceConnectionStatus.error,
        failure: _mapFailure(error),
      );
    }
  }

  void _handleRoomEvent(RoomEvent event) {
    if (event is TranscriptionEvent) {
      final localIdentity = _room?.localParticipant?.identity;
      final updatedTranscript = [...state.transcript];
      for (final segment in event.segments) {
        final text = segment.text.trim();
        if (text.isEmpty) continue;

        final line = VoiceTranscriptLine(
          id: segment.id,
          text: text,
          isAgent: event.participant.identity != localIdentity,
          isFinal: segment.isFinal,
        );
        final existingIndex = updatedTranscript.indexWhere(
          (entry) => entry.id == segment.id,
        );
        if (existingIndex >= 0) {
          updatedTranscript[existingIndex] = line;
        } else {
          updatedTranscript.add(line);
        }
      }
      state = state.copyWith(transcript: updatedTranscript);
      return;
    }

    if (event is RoomDisconnectedEvent) {
      unawaited(_cleanupRoom());
      state = const VoiceConnectionState();
    }
  }

  Future<void> _cleanupRoom() async {
    final listener = _roomListener;
    final room = _room;
    _roomListener = null;
    _room = null;
    await listener?.dispose();
    if (room != null) await room.disconnect();
  }

  Failure _mapFailure(Object error) {
    if (error is app_errors.AppException) {
      if (error is app_errors.NetworkException) {
        return NetworkFailure(message: error.message);
      }
      if (error is app_errors.TimeoutException) {
        return TimeoutFailure(message: error.message);
      }
      if (error is app_errors.AuthException) {
        return AuthFailure(message: error.message);
      }
      if (error is app_errors.ValidationException) {
        return ValidationFailure(message: error.message);
      }
      if (error is app_errors.ServerException) {
        return ServerFailure(message: error.message);
      }
      return UnknownFailure(message: error.message);
    }
    return const UnknownFailure(message: 'Unable to connect to the voice session.');
  }

  @override
  void dispose() {
    unawaited(_cleanupRoom());
    super.dispose();
  }
}