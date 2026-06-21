import 'dart:math';

import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/services/adapty_service.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PremiumCard extends StatefulWidget {
  const PremiumCard({super.key});

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPaywallOpening = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubscriptionViewModel>();
    final isPremium = vm.isPremium;
    final isAnonymous = context.watch<AuthViewModel>().isAnonymous;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: isPremium
            ? AppColors.premiumGradient
            : LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.08),
                  colorScheme.secondary.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isPremium
              ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
              : colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? const Color(0xFFF59E0B) : colorScheme.primary)
                .withValues(alpha: isPremium ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPremium
                    ? [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.1),
                      ]
                    : [
                        colorScheme.primary.withValues(alpha: 0.15),
                        colorScheme.secondary.withValues(alpha: 0.15),
                      ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPremium
                    ? Colors.white.withValues(alpha: 0.3)
                    : colorScheme.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_person_rounded,
              color: isPremium ? Colors.white : colorScheme.primary,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Text(
                isPremium
                    ? localizations.settings_premium_active
                    : localizations.settings_free_plan,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isPremium ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            isPremium
                ? localizations.settings_premium_active_desc
                : localizations.settings_free_plan_desc,
            style: AppTextStyles.bodySmall.copyWith(
              color: isPremium
                  ? Colors.white.withValues(alpha: 0.85)
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: isPremium
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                )
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: GlowBackgroundPainter(
                          animationValue: _controller.value,
                          baseColor1: colorScheme.primary,
                          baseColor2: colorScheme.primary.withValues(alpha: 0.7),
                          glowColor: Colors.white,
                          borderRadius: 12,
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      localizations.settings_upgrade_button,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          onTap: isPremium
              ? null
              : () async {
                  if (_isPaywallOpening) return;
                  if (isAnonymous) {
                    ToastService.showInfo(
                      localizations.settings_premium_signin_warning,
                      onTap: () {
                        context.push('/login?upgrade=true');
                      },
                    );
                  } else {
                    setState(() {
                      _isPaywallOpening = true;
                    });
                    try {
                      await AdaptyService.showPaywall(context);
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isPaywallOpening = false;
                        });
                      }
                    }
                  }
                },
        ),
      ),
    );
  }
}

class GlowBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor1;
  final Color baseColor2;
  final Color glowColor;
  final double borderRadius;

  GlowBackgroundPainter({
    required this.animationValue,
    required this.baseColor1,
    required this.baseColor2,
    required this.glowColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Clip to the button's rounded rectangle
    canvas.save();
    canvas.clipRRect(rrect);

    // Draw base background gradient
    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor1, baseColor2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Calculate moving glow center using a figure-8 Lissajous path
    final angle = animationValue * 2 * 3.141592653589793;
    final dx = size.width / 2 + sin(angle) * (size.width / 2 - 5);
    final dy = size.height / 2 + sin(angle * 2) * (size.height / 2 - 5);
    final glowCenter = Offset(dx, dy);

    // Draw the glowing light spot (orb)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: 0.35),
          glowColor.withValues(alpha: 0.12),
          glowColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: glowCenter, radius: size.width * 0.7));

    glowPaint.blendMode = BlendMode.screen;
    canvas.drawCircle(glowCenter, size.width * 0.7, glowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GlowBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.baseColor1 != baseColor1 ||
        oldDelegate.baseColor2 != baseColor2 ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}
