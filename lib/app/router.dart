import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/screens/conversation_history_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/journal/presentation/screens/journal_screen.dart';
import '../features/todo/presentation/screens/todo_screen.dart';
import '../features/wellness/presentation/screens/wellness_dashboard_screen.dart';
import '../features/yoga/presentation/screens/yoga_screen.dart';
import '../features/mood/presentation/screens/daily_checkin_screen.dart';
import '../features/mood/presentation/screens/mood_history_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/voice/presentation/screens/voice_screen.dart';

/// Central route constants
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String conversations = '/conversations';
  static const String chatLanding = '/chat';
  static const String dailyCheckIn = '/daily-checkin';
  static const String moodHistory = '/mood-history';
  static const String chat = '/chat/:conversationId';
  static const String voiceLive = '/voice-live';
  static const String yoga = '/yoga';
  static const String mentalWellness = '/mental-wellness';
  static const String journal = '/journal';
  static const String todo = '/todo';

  static String chatPath(String conversationId) => '/chat/$conversationId';
}

/// Global key for navigation state
final rootNavigatorKey = GlobalKey<NavigatorState>();

String? authRedirect({
  required bool authResolved,
  required bool isAuthenticated,
  required String currentLocation,
}) {
  if (!authResolved) {
    return currentLocation == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (!isAuthenticated) {
    final isAuthRoute = currentLocation == AppRoutes.login ||
        currentLocation == AppRoutes.register;
    return isAuthRoute ? null : AppRoutes.login;
  }

  final isAuthenticatedEntryRoute = currentLocation == AppRoutes.splash ||
      currentLocation == AppRoutes.login ||
      currentLocation == AppRoutes.register ||
      currentLocation == AppRoutes.onboarding;
  return isAuthenticatedEntryRoute ? AppRoutes.chatLanding : null;
}

/// Provider exposing configured GoRouter with centralized Auth & Onboarding guards
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authControllerProvider.notifier);
  final profileNotifier = ref.watch(profileControllerProvider.notifier);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: _CombinedListenable([authNotifier, profileNotifier]),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      return authRedirect(
        authResolved: !authState.isUnknown,
        isAuthenticated: authState.isAuthenticated,
        currentLocation: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.conversations,
        name: 'conversations',
        builder: (context, state) => const ConversationHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.dailyCheckIn,
        name: 'dailyCheckIn',
        builder: (context, state) => const DailyCheckInScreen(),
      ),
      GoRoute(
        path: AppRoutes.moodHistory,
        name: 'moodHistory',
        builder: (context, state) => const MoodHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatLanding,
        name: 'chatLanding',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'] ?? '';
          return ChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: AppRoutes.voiceLive,
        name: 'voiceLive',
        builder: (context, state) => const VoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.yoga,
        builder: (context, state) => const YogaScreen(),
      ),
      GoRoute(
        path: AppRoutes.mentalWellness,
        builder: (context, state) => const WellnessDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.journal,
        builder: (context, state) => const JournalScreen(),
      ),
      GoRoute(
        path: AppRoutes.todo,
        builder: (context, state) => const TodoScreen(),
      ),
    ],
  );
});

/// Bridge connecting multiple Riverpod StateNotifiers to Listenable for GoRouter
class _CombinedListenable extends ChangeNotifier {
  _CombinedListenable(List<StateNotifier<dynamic>> notifiers) {
    for (final notifier in notifiers) {
      notifier.addListener((_) => notifyListeners());
    }
  }
}
