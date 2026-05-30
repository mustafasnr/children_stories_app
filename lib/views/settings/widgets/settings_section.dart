import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/viewmodels/theme_viewmodel.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/views/settings/widgets/app_language_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final subVM = context.watch<SubscriptionViewModel>();
    final themeVM = context.watch<ThemeViewModel>();
    final isAnonymous = authVM.isAnonymous;

    return Column(
      children: [
        if (!isAnonymous) ...[
          _buildTile(
            context: context,
            icon: Icons.restore_rounded,
            title: 'Restore Purchases',
            onTap: () async {
              final restored = await subVM.restorePurchases();
              if (restored) {
                ToastService.showSuccess('Purchases restored!');
              } else {
                ToastService.showInfo('No active subscription found.');
              }
            },
          ),
          const SizedBox(height: 12),
        ],
        _buildSwitchTile(
          context: context,
          icon: themeVM.themeMode == ThemeMode.dark
              ? Icons.dark_mode_rounded
              : Icons.light_mode_rounded,
          title: 'Dark Mode',
          value: themeVM.themeMode == ThemeMode.dark,
          onChanged: (val) {
            themeVM.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
          },
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          context: context,
          icon: Icons.volume_up_rounded,
          title: 'Story Sounds',
          value: themeVM.storySoundsEnabled,
          iconColor: themeVM.isDarkMode
              ? const Color(0xFFFFB366)
              : const Color(0xFFF57C00),
          onChanged: (val) {
            themeVM.setStorySoundsEnabled(val);
          },
        ),
        const SizedBox(height: 12),
        AppLanguageSelector(),
        if (!isAnonymous) ...[
          const SizedBox(height: 12),
          _buildTile(
            context: context,
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            iconColor: AppColors.error,
            textColor: AppColors.error,
            trailing: const SizedBox.shrink(),
            onTap: () async {
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final activeIconColor = iconColor ?? AppColors.primary;
    final activeTextColor = textColor ?? AppColors.textPrimary;

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
              color: activeIconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeIconColor, size: 20),
          ),
          title: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: activeTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? iconColor,
    Color? switchActiveColor,
  }) {
    final activeIconColor = iconColor ?? AppColors.primary;
    final activeSwitchColor = switchActiveColor ?? AppColors.primary;
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
              color: activeIconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeIconColor, size: 20),
          ),
          title: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Switch.adaptive(
            value: value,
            activeTrackColor: activeSwitchColor,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
          onTap: () => onChanged(!value),
        ),
      ),
    );
  }
}
