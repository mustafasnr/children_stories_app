import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/views/settings/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SubscriptionSection extends StatelessWidget {
  const SubscriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final subVM = context.watch<SubscriptionViewModel>();
    final isAnonymous = authVM.isAnonymous;
    final isPremium = subVM.isPremium;

    return Column(
      children: [
        const PremiumCard(),
        if (isPremium) ...[
          const SizedBox(height: 12),
          _buildSubscriptionTile(context, isAnonymous, subVM),
        ],
      ],
    );
  }

  Widget _buildSubscriptionTile(
    BuildContext context,
    bool isAnonymous,
    SubscriptionViewModel subVM,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.textHint.withValues(alpha: 0.15),
          width: 1.2,
        ),
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
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.headphones_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Manage Subscription',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 20,
          ),
          onTap: () {
            if (isAnonymous) {
              ToastService.showInfo(
                'Please sign in to access subscriptions',
                onTap: () {
                  context.push('/login?upgrade=true');
                },
              );
            } else {
              subVM.openStoreSubscriptions();
            }
          },
        ),
      ),
    );
  }
}
