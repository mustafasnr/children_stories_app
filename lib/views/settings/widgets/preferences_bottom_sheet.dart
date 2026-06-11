import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/constants/app_icons.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AgeRangeOption {
  final String label;
  final String subtitle;
  final String iconPath;
  final int representativeAge;
  final String storyCount;

  const AgeRangeOption({
    required this.label,
    required this.subtitle,
    required this.iconPath,
    required this.representativeAge,
    required this.storyCount,
  });
}

const List<AgeRangeOption> ageRangeOptions = [
  AgeRangeOption(
    label: '2 - 5 Years Old',
    subtitle: 'Picture books, lullabies & simple tales',
    iconPath: 'assets/icons/magic.svg',
    representativeAge: 3,
    storyCount: '150+ Stories',
  ),
  AgeRangeOption(
    label: '6 - 9 Years Old',
    subtitle: 'Adventures, early readers & fairy tales',
    iconPath: 'assets/icons/rocket.svg',
    representativeAge: 7,
    storyCount: '350+ Stories',
  ),
  AgeRangeOption(
    label: '10 - 12 Years Old',
    subtitle: 'Chapter books, fantasy & mysteries',
    iconPath: 'assets/icons/books.svg',
    representativeAge: 11,
    storyCount: '200+ Stories',
  ),
];

String _getAgeTitle(int age, AppLocalizations l10n) {
  switch (age) {
    case 3:
      return l10n.onboarding_age_title_3;
    case 7:
      return l10n.onboarding_age_title_7;
    case 11:
      return l10n.onboarding_age_title_11;
    default:
      return '';
  }
}

String _getAgeSubtitle(int age, AppLocalizations l10n) {
  switch (age) {
    case 3:
      return l10n.onboarding_age_subtitle_3;
    case 7:
      return l10n.onboarding_age_subtitle_7;
    case 11:
      return l10n.onboarding_age_subtitle_11;
    default:
      return '';
  }
}

String _getAgeStories(int age, AppLocalizations l10n) {
  switch (age) {
    case 3:
      return l10n.onboarding_age_stories_3;
    case 7:
      return l10n.onboarding_age_stories_7;
    case 11:
      return l10n.onboarding_age_stories_11;
    default:
      return '';
  }
}

class PreferencesBottomSheet extends StatefulWidget {
  final int? initialAge;
  final String? initialGender;

  const PreferencesBottomSheet({
    super.key,
    this.initialAge,
    this.initialGender,
  });

  static void show(
    BuildContext context, {
    int? initialAge,
    String? initialGender,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PreferencesBottomSheet(
        initialAge: initialAge,
        initialGender: initialGender,
      ),
    );
  }

  @override
  State<PreferencesBottomSheet> createState() => _PreferencesBottomSheetState();
}

class _PreferencesBottomSheetState extends State<PreferencesBottomSheet> {
  int? _selectedAge;
  String? _selectedGender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedAge = widget.initialAge;
    _selectedGender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final localizations = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.preferences_title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.preferences_subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.close, color: AppColors.textHint),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Age Section
                    Text(
                      localizations.preferences_readers_age,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...ageRangeOptions.map((range) {
                      final isSelected = _selectedAge == range.representativeAge;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSelectionCard(
                          title: _getAgeTitle(range.representativeAge, localizations),
                          subtitle: _getAgeSubtitle(range.representativeAge, localizations),
                          badgeText: _getAgeStories(range.representativeAge, localizations),
                          leading: SvgPicture.asset(
                            range.iconPath,
                            width: 20,
                            height: 20,
                          ),
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedAge = range.representativeAge;
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    
                    // Gender Section
                    Text(
                      localizations.preferences_readers_gender,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSelectionCard(
                      title: localizations.gender_girl,
                      subtitle: localizations.gender_girl_subtitle,
                      leading: Icon(
                        AppIcons.genderFemale,
                        size: 20,
                        color: _selectedGender == 'girl'
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      isSelected: _selectedGender == 'girl',
                      onTap: () {
                        setState(() {
                          _selectedGender = 'girl';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSelectionCard(
                      title: localizations.gender_boy,
                      subtitle: localizations.gender_boy_subtitle,
                      leading: Icon(
                        AppIcons.genderMale,
                        size: 20,
                        color: _selectedGender == 'boy'
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      isSelected: _selectedGender == 'boy',
                      onTap: () {
                        setState(() {
                          _selectedGender = 'boy';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSelectionCard(
                      title: localizations.gender_unspecified,
                      subtitle: localizations.gender_unspecified_subtitle,
                      leading: Icon(
                        AppIcons.genderNeuter,
                        size: 20,
                        color: _selectedGender == 'unspecified' || _selectedGender == null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      isSelected: _selectedGender == 'unspecified' || _selectedGender == null,
                      onTap: () {
                        setState(() {
                          _selectedGender = 'unspecified';
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ElevatedButton(
                onPressed: _selectedAge == null || _isSaving
                    ? null
                    : () async {
                        setState(() {
                          _isSaving = true;
                        });
                        try {
                          await authVM.updateOnboardingData(
                            age: _selectedAge!,
                            gender: _selectedGender,
                          );
                          if (context.mounted) {
                            ToastService.showSuccess(localizations.preferences_update_success);
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ToastService.showError(localizations.preferences_update_failed(e.toString()));
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSaving = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        localizations.preferences_save_changes,
                        style: AppTextStyles.buttonLarge,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    String? badgeText,
    Widget? leading,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade200),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: leading,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badgeText,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? AppIcons.checkCircleFill
                      : AppIcons.checkCircleRegular,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade400),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
