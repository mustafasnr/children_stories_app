import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/constants/app_icons.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/profile_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/viewmodels/theme_viewmodel.dart';
import 'package:children_stories/views/settings/widgets/anon_upgrade_card.dart';
import 'package:children_stories/views/settings/widgets/subscription_section.dart';
import 'package:children_stories/views/settings/widgets/settings_section.dart';
import 'package:children_stories/views/settings/widgets/user_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                'Settings',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  if (isAnonymous) ...[
                    const AnonUpgradeCard(),
                  ] else ...[
                    UserHeader(
                      avatarUrl: avatarUrl,
                      name: name,
                      email: user?.email,
                      initials: profile?.initials,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Subscription status section
                  const SubscriptionSection(),

                  Divider(
                    color: AppColors.textHint.withValues(alpha: 0.15),
                    thickness: 1.2,
                  ),
                  const SizedBox(height: 36),

                  // Settings list
                  const SettingsSection(),
                  const SizedBox(height: 24),

                  // Text Size setting card
                  _buildTextSizeCard(context),

                  const SizedBox(height: 48),
                  Text('Story Time v1.0.0', style: AppTextStyles.labelSmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextSizeCard(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    final step = themeVM.storyTextSizeStep;
    final sizeLabel = step <= 3.0
        ? 'Small'
        : (step <= 7.0 ? 'Medium' : 'Large');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textHint.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.textSize,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Text Size',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: themeVM.isDarkMode
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sizeLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: themeVM.isDarkMode
                        ? Colors.white
                        : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.75,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                      ),
                      child: Slider(
                        value: step,
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        onChanged: (val) {
                          themeVM.setStoryTextSizeStep(val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textHint.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(
                '"Once upon a time, in a magical forest..."',
                style: AppTextStyles.readerText.copyWith(
                  fontSize: themeVM.storyTextSize,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
