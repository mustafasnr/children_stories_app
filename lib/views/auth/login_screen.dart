import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/views/auth/widgets/login_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                      localizations.login_title,
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      localizations.login_subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(flex: 3),
                    const LoginCard(),
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
    final localizations = AppLocalizations.of(context)!;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12.0,
          height: 1.5,
        ),
        children: [
          TextSpan(text: localizations.login_by_continuing),
          TextSpan(
            text: localizations.login_terms_of_service,
            recognizer: _termsRecognizer,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: localizations.login_and),
          TextSpan(
            text: localizations.login_privacy_policy,
            recognizer: _privacyRecognizer,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: localizations.login_agree_suffix),
        ],
      ),
    );
  }
}
