import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/views/auth/login_screen.dart';
import 'package:children_stories/views/book_detail/book_detail_screen.dart';
import 'package:children_stories/views/explore/explore_screen.dart';
import 'package:children_stories/views/search/search_screen.dart';
import 'package:children_stories/views/library/library_screen.dart';
import 'package:children_stories/views/settings/settings_screen.dart';
import 'package:children_stories/views/main/main_scaffold.dart';
import 'package:children_stories/views/onboarding/onboarding_screen.dart';
import 'package:children_stories/views/reader/reader_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      navigatorKey: ToastService.navigatorKey,
      initialLocation: '/explore',
      refreshListenable: authViewModel,
      redirect: (context, state) {
        final isInitialized = authViewModel.isInitialized;
        if (!isInitialized) return null; // Wait for initial auth setup

        // Don't redirect during active sign-in to prevent flicker
        if (authViewModel.isLoading) return null;

        final hasCompletedOnboarding = authViewModel.hasCompletedOnboarding;
        final isLoggedIn = authViewModel.isLoggedIn;
        final hasFinishedAuthSelection = authViewModel.hasFinishedAuthSelection;

        final location = state.matchedLocation;
        final isOnboarding = location == '/onboarding';
        final isLogin = location == '/login';

        // 1. Onboarding must be completed first
        if (!hasCompletedOnboarding) {
          if (!isOnboarding) return '/onboarding';
          return null;
        }

        // 2. User must be logged in (anonymous or permanent)
        if (!isLoggedIn) {
          if (!isLogin) return '/login';
          return null;
        }

        // 3. Must choose to proceed if they are anonymous guest
        if (!hasFinishedAuthSelection) {
          if (!isLogin) return '/login';
          return null;
        }

        // 4. Bypass onboarding/login if fully set up
        if (isOnboarding || isLogin) {
          final isUpgrade = state.uri.queryParameters['upgrade'] == 'true';
          if (isLogin && isUpgrade && authViewModel.isAnonymous) {
            return null; // Allow upgrading users to proceed or pop manually back to Settings
          }
          return '/explore';
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
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/explore',
                  name: 'explore',
                  builder: (_, _) => const ExploreScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  name: 'search',
                  builder: (_, _) => const SearchScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/library',
                  name: 'library',
                  builder: (_, _) => const LibraryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  name: 'settings',
                  builder: (_, _) => const SettingsScreen(),
                ),
              ],
            ),
          ],
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
      ],
    );
  }
}
