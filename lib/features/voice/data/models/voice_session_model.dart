import '../../domain/entities/voice_session.dart';

class VoiceSessionModel extends VoiceSession {
  const VoiceSessionModel({
    required super.url,
    required super.room,
    required super.participantIdentity,
    required super.token,
  });

  factory VoiceSessionModel.fromJson(Map<String, dynamic> json) {
    return VoiceSessionModel(
      url: json['url'] as String,
      room: json['room'] as String,
      participantIdentity: json['participant_identity'] as String,
      token: json['token'] as String,
    );
  }

  VoiceSession toEntity() => this;
}