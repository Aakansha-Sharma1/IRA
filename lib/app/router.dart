import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/authenticated_home_placeholder.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

/// Central route constants
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String profile = '/profile';
}

/// Global key for navigation state
final rootNavigatorKey = GlobalKey<NavigatorState>();

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
      final profileState = ref.read(profileControllerProvider);
      final currentLoc = state.matchedLocation;

      // 1. Initial auth state resolving
      if (authState.isUnknown) {
        return currentLoc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // 2. Unauthenticated user
      if (!authState.isAuthenticated) {
        final isAuthRoute =
            currentLoc == AppRoutes.login || currentLoc == AppRoutes.register;
        return isAuthRoute ? null : AppRoutes.login;
      }

      // 3. User is authenticated:
      // If profile state is still resolving, hold on splash to prevent flashing protected screens
      if (profileState.isInitial || profileState.isLoading) {
        return currentLoc == AppRoutes.splash ? null : AppRoutes.splash;
      }

      // 4. Onboarding check:
      // If profile is missing or onboarding is not marked complete, direct to Onboarding
      final needsOnboarding =
          profileState.isNotFound || !profileState.hasCompletedOnboarding;
      if (needsOnboarding) {
        return currentLoc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      // 5. User is fully authenticated & onboarded:
      // Prevent visiting splash, auth, or onboarding screens
      if (currentLoc == AppRoutes.splash ||
          currentLoc == AppRoutes.login ||
          currentLoc == AppRoutes.register ||
          currentLoc == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      // 6. Allow access to requested authenticated route (/home, /profile)
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
        builder: (context, state) => const AuthenticatedHomePlaceholder(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
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
