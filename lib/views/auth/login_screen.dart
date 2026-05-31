import 'package:children_stories/app/app.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/views/auth/widgets/social_login_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android: white icons
        statusBarBrightness: Brightness.dark, // iOS: white text/icons
      ),
      child: Stack(
        children: [
          // 1. Magical Background Image covering the upper part of the screen
          Positioned.fill(
            child: Image.asset('assets/images/login_bg.jpg', fit: BoxFit.cover),
          ),
          // 2. Smooth fade-out gradient mask from transparent to black
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          // 3. Transparent Scaffold for UI elements
          Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 1),
                      builder: (_, v, child) => Opacity(
                        opacity: v,
                        child: Transform.rotate(angle: v * 0.15, child: child),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Story Time',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Magical stories for curious minds',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(flex: 3),
                    const _LoginCard(),
                    const Spacer(flex: 1),
                    const _TermsText(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsText extends StatefulWidget {
  const _TermsText();

  @override
  State<_TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<_TermsText> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openTerms() {
    debugPrint('Terms of Service clicked - Navigate to URL');
  }

  void _openPrivacy() {
    debugPrint('Privacy Policy clicked - Navigate to URL');
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12.0,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            recognizer: _termsRecognizer,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: '\nand '),
          TextSpan(
            text: 'Privacy Policy',
            recognizer: _privacyRecognizer,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
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
        return ClipRRect(
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
                    'Get Started',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to start your reading adventure',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SocialLoginButton(
                    label: 'Continue with Google',
                    emoji: '🔵',
                    svgPath: 'assets/icons/google_icon.svg',
                    labelColor: Colors.black87,
                    bgColor: Colors.white,
                    isLoading: authVM.isLoading,
                    onTap: authVM.isLoading
                        ? null
                        : () async {
                            if (authVM.isLoggedIn && authVM.isAnonymous) {
                              await authVM.linkGoogle();
                            } else {
                              await authVM.signInWithGoogle();
                            }
                            if (!context.mounted) return;
                            if (isUpgrade && !authVM.isAnonymous && authVM.error == null) {
                              RestartWidget.restartApp(context);
                            }
                          },
                  ),
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 16),
                    SocialLoginButton(
                      label: 'Continue with Apple',
                      emoji: '🍎',
                      labelColor: Colors.white,
                      bgColor: Colors.black,
                      isLoading: authVM.isLoading,
                      onTap: authVM.isLoading
                          ? null
                          : () async {
                              if (authVM.isLoggedIn && authVM.isAnonymous) {
                                await authVM.linkApple();
                              } else {
                                await authVM.signInWithApple();
                              }
                              if (!context.mounted) return;
                              if (isUpgrade && !authVM.isAnonymous && authVM.error == null) {
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
                      isUpgrade ? 'Not Now' : 'Continue without signing in',
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
        );
      },
    );
  }
}
