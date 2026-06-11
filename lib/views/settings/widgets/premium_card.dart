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
                    return CustomPaint(
                      foregroundPainter: GlowBorderPainter(
                        animationValue: _controller.value,
                        color: Colors.white,
                        borderRadius: 12,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isAnonymous) {
                            ToastService.showInfo(
                              localizations.settings_premium_signin_warning,
                              onTap: () {
                                context.push('/login?upgrade=true');
                              },
                            );
                          } else {
                            AdaptyService.showPaywall(context);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
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
                    ),
                  ),
                ),
          onTap: isPremium
              ? null
              : () {
                  if (isAnonymous) {
                    ToastService.showInfo(
                      localizations.settings_premium_signin_warning,
                      onTap: () {
                        context.push('/login?upgrade=true');
                      },
                    );
                  } else {
                    AdaptyService.showPaywall(context);
                  }
                },
        ),
      ),
    );
  }
}

class GlowBorderPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double borderRadius;

  GlowBorderPainter({
    required this.animationValue,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final totalLength = metric.length;

    // Glowing segment is 22% of total perimeter
    final segmentLength = totalLength * 0.22;
    final start = (animationValue * totalLength) % totalLength;
    final end = start + segmentLength;

    Path extractPath;
    if (end <= totalLength) {
      extractPath = metric.extractPath(start, end);
    } else {
      extractPath = metric.extractPath(start, totalLength);
      extractPath.addPath(
        metric.extractPath(0.0, end % totalLength),
        Offset.zero,
      );
    }

    // Layer 1: Outer glow (very soft and wide)
    final outerGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(extractPath, outerGlowPaint);

    // Layer 2: Inner glow (brighter, slightly less blurred)
    final innerGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    canvas.drawPath(extractPath, innerGlowPaint);

    // Layer 3: Soft highlight core (anchors the light source, blurred slightly to stay soft)
    final corePaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);
    canvas.drawPath(extractPath, corePaint);
  }

  @override
  bool shouldRepaint(covariant GlowBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
