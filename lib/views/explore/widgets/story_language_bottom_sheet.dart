import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/constants/app_icons.dart';
import 'package:children_stories/data/models/language_model.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

class StoryLanguageBottomSheet extends StatelessWidget {
  final List<Language> languages;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const StoryLanguageBottomSheet({
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
      builder: (context) => StoryLanguageBottomSheet(
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
        maxHeight: MediaQuery.of(context).size.height * 0.7,
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
            'Select Stories Language',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = index == selectedIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceVariant
                          : AppColors.surface,
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
                        onTap: () {
                          onSelected(index);
                          Navigator.pop(context);
                        },
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              CountryFlags.flag(
                                lang.countryCode,
                                width: 30,
                                height: 22,
                                borderRadius: 4,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      lang.name,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withValues(
                                                alpha: 0.15,
                                              )
                                            : (isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.08,
                                                    )
                                                  : AppColors.surfaceVariant),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${lang.storyCount} Stories',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
