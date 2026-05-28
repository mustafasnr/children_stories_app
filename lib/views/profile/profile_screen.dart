import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/profile_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/core/services/adapty_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ProfileViewModel();
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId != null) _vm.loadProfile(userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionViewModel>().checkSubscriptionStatus();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final authVM = context.read<AuthViewModel>();
          final subVM = context.watch<SubscriptionViewModel>();
          final user = authVM.currentUser;
          final profile = vm.profile;
          final avatarUrl =
              profile?.avatarUrl ??
              user?.userMetadata?['avatar_url'] as String? ??
              user?.userMetadata?['picture'] as String?;
          final name =
              profile?.displayName ??
              user?.userMetadata?['full_name'] as String? ??
              user?.userMetadata?['name'] as String? ??
              'Reader';

          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                // App bar with gradient header
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: avatarUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: avatarUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: AppColors.primaryLight,
                                        child: Center(
                                          child: Text(
                                            profile?.initials ?? '?',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              name,
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Premium status card
                        _buildPremiumCard(context, subVM),
                        const SizedBox(height: 20),
                        // Settings list
                        _buildSection([
                          _tile(
                            icon: Icons.headphones_rounded,
                            label: 'Subscription',
                            onTap: () => AdaptyService.showPaywall(context),
                          ),
                          _tile(
                            icon: Icons.restore_rounded,
                            label: 'Restore Purchases',
                            onTap: () async {
                              final restored = await subVM.restorePurchases();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      restored
                                          ? '✅ Purchases restored!'
                                          : 'No active subscription found.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ]),
                        const SizedBox(height: 16),
                        _buildSection([
                          _tile(
                            icon: Icons.logout_rounded,
                            label: 'Sign Out',
                            labelColor: AppColors.error,
                            onTap: () async {
                              await context.read<AuthViewModel>().signOut();
                              if (context.mounted) context.go('/login');
                            },
                          ),
                        ]),
                        const SizedBox(height: 40),
                        Text(
                          'Story Time v1.0.0',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, SubscriptionViewModel vm) {
    final isPremium = vm.isPremium;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isPremium
            ? AppColors.premiumGradient
            : const LinearGradient(
                colors: [AppColors.surfaceVariant, AppColors.surface],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? AppColors.premium : AppColors.textHint)
                .withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(isPremium ? '👑' : '🔒', style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Premium Active' : 'Free Plan',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isPremium ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isPremium
                      ? 'All stories & audio unlocked'
                      : 'Upgrade to unlock everything',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isPremium
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            ElevatedButton(
              onPressed: () => AdaptyService.showPaywall(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: AppTextStyles.buttonLarge.copyWith(fontSize: 13),
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: tiles),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: labelColor ?? AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
