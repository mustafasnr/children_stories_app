import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/services/adapty_service.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubscriptionViewModel>();
    final isPremium = vm.isPremium;
    final isAnonymous = context.watch<AuthViewModel>().isAnonymous;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                isPremium ? 'Premium Active' : 'Free Plan',
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
                ? 'All stories & audio unlocked'
                : 'Upgrade to unlock everything',
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
              : Container(
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
                            'Please sign in first to purchase Premium!',
                          );
                          context.push('/login?upgrade=true');
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
                          'Upgrade',
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
          onTap: isPremium
              ? null
              : () {
                  if (isAnonymous) {
                    ToastService.showInfo(
                      'Please sign in first to purchase Premium!',
                    );
                    context.push('/login?upgrade=true');
                  } else {
                    AdaptyService.showPaywall(context);
                  }
                },
        ),
      ),
    );
  }
}
