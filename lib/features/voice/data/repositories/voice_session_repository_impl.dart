import '../../domain/entities/voice_session.dart';
import '../../domain/repositories/voice_session_repository.dart';
import '../datasources/voice_session_remote_data_source.dart';

class VoiceSessionRepositoryImpl implements VoiceSessionRepository {
  final VoiceSessionRemoteDataSource remoteDataSource;

  VoiceSessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<VoiceSession> createSession() async {
    final model = await remoteDataSource.createSession();
    return model.toEntity();
  }
}