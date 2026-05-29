import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/views/auth/login_screen.dart';
import 'package:children_stories/views/book_detail/book_detail_screen.dart';
import 'package:children_stories/views/home/home_screen.dart';
import 'package:children_stories/views/onboarding/onboarding_screen.dart';
import 'package:children_stories/views/profile/profile_screen.dart';
import 'package:children_stories/views/reader/reader_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/home',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isLoggedIn = authViewModel.isLoggedIn;
        final isInitialized = authViewModel.isInitialized;
        if (!isInitialized) return null; // Wait for initial auth setup

        final hasCompletedOnboarding = authViewModel.hasCompletedOnboarding;
        final hasFinishedAuthSelection = authViewModel.hasFinishedAuthSelection;

        final location = state.matchedLocation;
        final isOnboarding = location == '/onboarding';
        final isLogin = location == '/login';

        // 1. Safety fallback if not logged in (e.g. Supabase session issue)
        if (!isLoggedIn) {
          if (!isLogin && !isOnboarding) return '/login';
          return null;
        }

        // 2. Redirect to onboarding if not yet completed
        if (!hasCompletedOnboarding) {
          if (!isOnboarding) return '/onboarding';
          return null;
        }

        // 3. Redirect to login page if they haven't explicitly chosen to proceed
        if (!hasFinishedAuthSelection) {
          if (!isLogin) return '/login';
          return null;
        }

        // 4. Bypassing auth views once authenticated and finished onboarding
        if (isOnboarding || isLogin) {
          if (authViewModel.isAnonymous) return null;
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, _) => const HomeScreen(),
        ),
        GoRoute(
          path: '/book/:id',
          name: 'book',
          builder: (_, state) =>
              BookDetailScreen(bookId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/reader/:id',
          name: 'reader',
          builder: (_, state) =>
              ReaderScreen(bookId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (_, _) => const ProfileScreen(),
        ),
      ],
    );
  }
}
