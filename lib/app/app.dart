import 'package:children_stories/app/routes.dart';
import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_theme.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/viewmodels/theme_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChildrenStoriesApp extends StatelessWidget {
  const ChildrenStoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SubscriptionViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const _AppContent(),
    );
  }
}

class _AppContent extends StatefulWidget {
  const _AppContent();

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authVM = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(authVM);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthViewModel>();
    final themeVM = context.watch<ThemeViewModel>();

    // Change this variable to force a specific theme during development
    // e.g. ThemeMode.light, ThemeMode.dark, or themeVM.themeMode
    final activeThemeMode = themeVM.themeMode;

    // Update dynamic AppColors current scheme based on activeThemeMode
    final isDark =
        activeThemeMode == ThemeMode.dark ||
        (activeThemeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    AppColors.current = isDark ? AppColors.darkScheme : AppColors.lightScheme;

    return MaterialApp.router(
      title: 'Story Time',
      themeMode: activeThemeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
