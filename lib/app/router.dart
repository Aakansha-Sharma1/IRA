import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/goals/presentation/screens/goals_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/insights/presentation/screens/insights_screen.dart';
import '../features/journal/presentation/screens/journal_screen.dart';
import '../features/mood/presentation/screens/mood_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/safety/presentation/screens/safety_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/voice/presentation/screens/voice_screen.dart';
import '../features/wellness/presentation/screens/wellness_screen.dart';

/// Central route constants
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String voice = '/voice';
  static const String mood = '/mood';
  static const String journal = '/journal';
  static const String goals = '/goals';
  static const String analytics = '/analytics';
  static const String insights = '/insights';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String safety = '/safety';
  static const String wellness = '/wellness';
}

/// Global key for navigation state
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider exposing configured GoRouter with centralized Auth & Onboarding guards
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authControllerProvider.notifier);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: _RiverpodListenable(authNotifier),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      final currentLoc = state.matchedLocation;

      // 1. App is initializing / determining initial auth state
      if (authState.isUnknown) {
        return currentLoc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isAuthenticated = authState.isAuthenticated;
      final hasCompletedOnboarding = authState.hasCompletedOnboarding;
      final isAuthRoute = currentLoc == AppRoutes.login || currentLoc == AppRoutes.register;

      // 2. User is unauthenticated
      if (!isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // 3. User is authenticated but hasn't completed onboarding
      if (!hasCompletedOnboarding) {
        return currentLoc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      // 4. User is authenticated and completed onboarding: prevent visiting auth / splash / onboarding
      if (currentLoc == AppRoutes.splash ||
          currentLoc == AppRoutes.login ||
          currentLoc == AppRoutes.register ||
          currentLoc == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      // 5. Allow access to requested feature route
      return null;
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
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.voice,
        name: 'voice',
        builder: (context, state) => const VoiceScreen(),
      ),
      GoRoute(
        path: AppRoutes.mood,
        name: 'mood',
        builder: (context, state) => const MoodScreen(),
      ),
      GoRoute(
        path: AppRoutes.journal,
        name: 'journal',
        builder: (context, state) => const JournalScreen(),
      ),
      GoRoute(
        path: AppRoutes.goals,
        name: 'goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.insights,
        name: 'insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.safety,
        name: 'safety',
        builder: (context, state) => const SafetyScreen(),
      ),
      GoRoute(
        path: AppRoutes.wellness,
        name: 'wellness',
        builder: (context, state) => const WellnessScreen(),
      ),
    ],
  );
});

/// Bridge connecting Riverpod StateNotifier to Listenable for GoRouter
class _RiverpodListenable extends ChangeNotifier {
  _RiverpodListenable(StateNotifier<dynamic> notifier) {
    notifier.addListener((_) => notifyListeners());
  }
}
