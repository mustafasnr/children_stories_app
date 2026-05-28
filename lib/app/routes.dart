import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/views/auth/login_screen.dart';
import 'package:children_stories/views/book_detail/book_detail_screen.dart';
import 'package:children_stories/views/home/home_screen.dart';
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
        final location = state.matchedLocation;
        final isLogin = location == '/login';

        if (!isLoggedIn && !isLogin) return '/login';
        if (isLoggedIn && isLogin) return '/home';
        return null;
      },
      routes: [
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
