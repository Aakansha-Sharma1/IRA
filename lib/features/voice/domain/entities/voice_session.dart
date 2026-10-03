class VoiceSession {
  final String url;
  final String room;
  final String participantIdentity;
  final String token;

  const VoiceSession({
    required this.url,
    required this.room,
    required this.participantIdentity,
    required this.token,
  });
}