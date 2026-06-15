import 'dart:io';
import 'dart:ui';

import 'package:children_stories/app/app.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/views/auth/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isUpgrade =
        GoRouterState.of(context).uri.queryParameters['upgrade'] == 'true';
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        if (authVM.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ToastService.showError(authVM.error!);
            authVM.clearError();
          });
        }
        return AbsorbPointer(
          absorbing: authVM.isLoading,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: size.width * 0.75,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      localizations.login_get_started,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizations.login_card_subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SocialLoginButton(
                      label: isUpgrade
                          ? localizations.login_connect_google
                          : localizations.login_continue_google,
                      emoji: '🔵',
                      svgPath: 'assets/icons/google_icon.svg',
                      labelColor: Colors.black87,
                      bgColor: Colors.white,
                      isLoading: authVM.isLoading,
                      onTap: authVM.isLoading
                          ? null
                          : () async {
                              if (authVM.isLoading) return;
                              await authVM.signInWithGoogle();
                              if (!context.mounted) return;
                              if (authVM.isLoggedIn && authVM.error == null) {
                                RestartWidget.restartApp(context);
                              }
                            },
                    ),
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        label: isUpgrade
                            ? localizations.login_connect_apple
                            : localizations.login_continue_apple,
                        emoji: '🍎',
                        labelColor: Colors.white,
                        bgColor: Colors.black,
                        isLoading: authVM.isLoading,
                        onTap: authVM.isLoading
                            ? null
                            : () async {
                                if (authVM.isLoading) return;
                                await authVM.signInWithApple();
                                if (!context.mounted) return;
                                if (authVM.isLoggedIn && authVM.error == null) {
                                  RestartWidget.restartApp(context);
                                }
                              },
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: authVM.isLoading
                          ? null
                          : () async {
                              if (authVM.isLoading) return;
                              if (authVM.isLoggedIn && authVM.isAnonymous) {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/explore');
                                }
                              } else {
                                await authVM.continueWithoutSignIn();
                              }
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.85),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        isUpgrade ? localizations.login_not_now : localizations.login_continue_without_sign_in,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
