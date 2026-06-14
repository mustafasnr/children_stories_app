import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/constants/app_icons.dart';
import 'package:children_stories/data/models/language_model.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/settings_viewmodel.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blueColor = isDark
        ? const Color(0xFF64B5F6)
        : const Color(0xFF0288D1);

    // Watch SettingsViewModel to register a rebuild dependency when settings changes
    final settingsVM = context.watch<SettingsViewModel>();

    final languages = const [
      Language(id: 1, code: 'en', name: 'English', flagEmoji: '🇬🇧'),
      Language(id: 2, code: 'tr', name: 'Türkçe', flagEmoji: '🇹🇷'),
    ];
    final selectedIndex = languages.indexWhere(
      (l) => l.code == settingsVM.appLanguageCode,
    );
    final activeIndex = selectedIndex == -1 ? 0 : selectedIndex;
    final currentLanguage = languages[activeIndex];

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
              color: blueColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.language_rounded, color: blueColor, size: 20),
          ),
          title: Text(
            localizations.app_language,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguage.code.toUpperCase(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
          onTap: () {
            AppLanguageBottomSheet.show(
              context,
              languages: languages,
              selectedIndex: activeIndex,
              onSelected: (index) {
                settingsVM.setAppLanguage(languages[index].code);
              },
            );
          },
        ),
      ),
    );
  }
}

class AppLanguageBottomSheet extends StatelessWidget {
  final List<Language> languages;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppLanguageBottomSheet({
    super.key,
    required this.languages,
    required this.selectedIndex,
    required this.onSelected,
  });

  static void show(
    BuildContext context, {
    required List<Language> languages,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AppLanguageBottomSheet(
        languages: languages,
        selectedIndex: selectedIndex,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select App Language',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = index == selectedIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLanguageItem(
                  context: context,
                  name: lang.name,
                  countryCode: lang.countryCode,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () {
                    onSelected(index);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String name,
    required String countryCode,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.shade300),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04)),
          highlightColor: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                CountryFlag.fromCountryCode(
                  countryCode,
                  theme: const ImageTheme(
                    width: 30,
                    height: 22,
                    shape: RoundedRectangle(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? AppIcons.checkCircleFill
                      : AppIcons.checkCircleRegular,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.grey.shade400),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
