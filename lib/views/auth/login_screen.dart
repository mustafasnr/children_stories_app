import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/views/auth/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            _buildBgCircles(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 56),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildFeatures(),
                        const Spacer(),
                        const SizedBox(height: 32),
                        _buildCard(context),
                        const SizedBox(height: 20),
                        _buildTerms(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBgCircles() {
    return Stack(
      children: [
        Positioned(top: -80, right: -80, child: _circle(260, 0.05)),
        Positioned(bottom: -100, left: -60, child: _circle(300, 0.05)),
      ],
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );

  Widget _buildHeader() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 700),
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.scale(scale: 0.6 + v * 0.4, child: child),
          ),
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text('📚', style: TextStyle(fontSize: 56)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Story Time',
          style: AppTextStyles.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Magical stories for curious minds',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final items = [
      ('📖', 'Free Stories'),
      ('🌍', 'Languages'),
      ('🎧', 'Audio'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items
          .map(
            (f) => Column(
              children: [
                Text(f.$1, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  f.$2,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Get Started',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to start your reading adventure',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (authVM.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authVM.error!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: authVM.clearError,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SocialLoginButton(
                    label: 'Continue with Google',
                    emoji: '🔵',
                    labelColor: Colors.black87,
                    bgColor: Colors.white,
                    isLoading: authVM.isLoading,
                    onTap: authVM.isLoading
                        ? null
                        : () => authVM.signInWithGoogle(),
                  ),
                  if (Platform.isIOS) ...[
                    const SizedBox(height: 12),
                    SocialLoginButton(
                      label: 'Continue with Apple',
                      emoji: '🍎',
                      labelColor: Colors.white,
                      bgColor: Colors.black,
                      isLoading: authVM.isLoading,
                      onTap: authVM.isLoading
                          ? null
                          : () => authVM.signInWithApple(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: authVM.isLoading
                        ? null
                        : () => authVM.continueWithoutSignIn(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Continue without signing in',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        decoration: TextDecoration.underline,
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

  Widget _buildTerms() {
    return Text(
      'By continuing you agree to our Terms of Service\nand Privacy Policy.',
      style: AppTextStyles.labelSmall.copyWith(
        color: Colors.white.withValues(alpha: 0.5),
      ),
      textAlign: TextAlign.center,
    );
  }
}
