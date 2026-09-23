/// Central registry of IRA backend endpoints.
/// Note: Endpoints are paths relative to API_BASE_URL.
abstract final class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';

  // Onboarding
  static const String onboarding = '/onboarding';

  // Wellness & Mood
  static const String mood = '/mood';
  static const String wellnessCheckIn = '/wellness/check-in';
  static const String journal = '/journal';
  static const String goals = '/goals';

  // Analytics & Insights
  static const String analyticsSummary = '/analytics/summary';
  static const String insights = '/insights';

  // Conversational & Multimodal (Chat, Voice, Avatar)
  static const String chatMessages = '/chat/messages';
  static const String voiceSession = '/voice/session';

  // Safety & Crisis Intervention
  static const String safetyEvaluation = '/safety/evaluate';
  static const String emergencyResources = '/safety/resources';

  // User Profile
  static const String profile = '/profile';

  // Conversations
  static const String conversations = '/conversations';

  static String conversation(String id) => '/conversations/$id';

  static String conversationMessages(String id) => '/conversations/$id/messages';
}
