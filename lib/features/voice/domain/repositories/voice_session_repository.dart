import '../entities/voice_session.dart';

abstract class VoiceSessionRepository {
  Future<VoiceSession> createSession();
}