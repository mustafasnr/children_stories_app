import 'dart:async';
import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/profile_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/viewmodels/theme_viewmodel.dart';
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

  void _showAuthRequiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please sign in first to purchase Premium!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.push('/login');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final authVM = context.read<AuthViewModel>();
          final subVM = context.watch<SubscriptionViewModel>();
          final themeVM = context.watch<ThemeViewModel>();

          final isAnonymous = authVM.isAnonymous;
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
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Profile',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  if (isAnonymous) ...[
                    const _AnonUpgradeCard(),
                  ] else ...[
                    _buildUserHeader(
                      avatarUrl,
                      name,
                      user?.email,
                      profile?.initials,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Premium status card
                  _buildPremiumCard(context, subVM, isAnonymous),
                  const SizedBox(height: 20),

                  // Settings list
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.textHint.withValues(alpha: 0.15),
                        width: 1.2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(19),
                              ),
                            ),
                            leading: Icon(
                              Icons.headphones_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            title: Text(
                              'Subscription',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onTap: () {
                              if (isAnonymous) {
                                _showAuthRequiredSnackBar(context);
                              } else {
                                AdaptyService.showPaywall(context);
                              }
                            },
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                            color: AppColors.textHint.withValues(alpha: 0.15),
                          ),
                          if (!isAnonymous) ...[
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              shape: const RoundedRectangleBorder(),
                              leading: Icon(
                                Icons.restore_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              title: Text(
                                'Restore Purchases',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textHint,
                                size: 20,
                              ),
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
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 0,
                              endIndent: 0,
                              color: AppColors.textHint.withValues(alpha: 0.15),
                            ),
                          ],
                          SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(19),
                              ),
                            ),
                            secondary: Icon(
                              themeVM.themeMode == ThemeMode.dark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            title: Text(
                              'Dark Mode',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            value: themeVM.themeMode == ThemeMode.dark,
                            activeTrackColor: AppColors.primary,
                            activeThumbColor: Colors.white,
                            onChanged: (val) {
                              themeVM.setThemeMode(
                                val ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!isAnonymous) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.textHint.withValues(alpha: 0.15),
                          width: 1.2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(19),
                                ),
                              ),
                              leading: Icon(
                                Icons.logout_rounded,
                                color: AppColors.error,
                                size: 22,
                              ),
                              title: Text(
                                'Sign Out',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                              onTap: () async {
                                await context.read<AuthViewModel>().signOut();
                                if (context.mounted) context.go('/login');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  Text('Story Time v1.0.0', style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(
    String? avatarUrl,
    String name,
    String? email,
    String? initials,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: avatarUrl != null
                  ? CachedNetworkImage(imageUrl: avatarUrl, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primaryLight,
                      child: Center(
                        child: Text(
                          initials ?? '?',
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (email != null && email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context,
    SubscriptionViewModel vm,
    bool isAnonymous,
  ) {
    final isPremium = vm.isPremium;
    return Container(
      decoration: BoxDecoration(
        color: isPremium ? Colors.transparent : null,
        gradient: isPremium
            ? AppColors.premiumGradient
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.accentLight.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium
              ? AppColors.premium.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? AppColors.premium : AppColors.primary)
                .withValues(alpha: isPremium ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.5),
          ),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPremium
                    ? [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.1),
                      ]
                    : [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.accent.withValues(alpha: 0.15),
                      ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPremium
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.lock_person_rounded,
              color: isPremium ? Colors.white : AppColors.primary,
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Text(
                isPremium ? 'Premium Active' : 'Free Plan',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isPremium ? Colors.white : AppColors.textPrimary,
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
                  : AppColors.textSecondary,
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
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
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
                          _showAuthRequiredSnackBar(context);
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
                    _showAuthRequiredSnackBar(context);
                  } else {
                    AdaptyService.showPaywall(context);
                  }
                },
        ),
      ),
    );
  }
}

class _AnonUpgradeCard extends StatefulWidget {
  const _AnonUpgradeCard();

  @override
  State<_AnonUpgradeCard> createState() => _AnonUpgradeCardState();
}

class _AnonUpgradeCardState extends State<_AnonUpgradeCard> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 300;
  final int _totalSlides = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      const _CarouselSlideData(
        emoji: '📚',
        title: 'Create Your Library',
        description:
            'Save your favorite stories and access them anytime, anywhere.',
      ),
      const _CarouselSlideData(
        emoji: '🎧',
        title: 'Audio Narrations',
        description: 'Listen to high-quality voiceovers and narrations.',
      ),
      const _CarouselSlideData(
        emoji: '✨',
        title: 'Sync Across Devices',
        description: 'Never lose your reading progress or saved stats.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final slide = slides[index % _totalSlides];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          slide.emoji,
                          style: const TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalSlides, (index) {
              final isActive = (_currentPage % _totalSlides) == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign In / Register',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselSlideData {
  final String emoji;
  final String title;
  final String description;

  const _CarouselSlideData({
    required this.emoji,
    required this.title,
    required this.description,
  });
}
