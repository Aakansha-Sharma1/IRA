import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/voice_session_remote_data_source.dart';
import '../../data/repositories/voice_session_repository_impl.dart';
import '../../domain/repositories/voice_session_repository.dart';
import '../controllers/voice_connection_controller.dart';
import '../controllers/voice_connection_state.dart';

final voiceSessionRemoteDataSourceProvider =
    Provider<VoiceSessionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VoiceSessionRemoteDataSourceImpl(apiClient: apiClient);
});

final voiceSessionRepositoryProvider = Provider<VoiceSessionRepository>((ref) {
  final remoteDataSource = ref.watch(voiceSessionRemoteDataSourceProvider);
  return VoiceSessionRepositoryImpl(remoteDataSource: remoteDataSource);
});

final voiceConnectionControllerProvider =
    StateNotifierProvider<VoiceConnectionController, VoiceConnectionState>((ref) {
  final repository = ref.watch(voiceSessionRepositoryProvider);
  return VoiceConnectionController(repository);
});