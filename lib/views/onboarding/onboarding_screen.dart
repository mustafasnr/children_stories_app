import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/constants/app_icons.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AgeRange {
  final String label;
  final String subtitle;
  final String iconPath;
  final int representativeAge;
  final String storyCount;

  const AgeRange({
    required this.label,
    required this.subtitle,
    required this.iconPath,
    required this.representativeAge,
    required this.storyCount,
  });
}

const List<AgeRange> ageRanges = [
  AgeRange(
    label: '2 - 5 Years Old',
    subtitle: 'Picture books, lullabies & simple tales',
    iconPath: 'assets/icons/magic.svg',
    representativeAge: 3,
    storyCount: '150+ Stories',
  ),
  AgeRange(
    label: '6 - 9 Years Old',
    subtitle: 'Adventures, early readers & fairy tales',
    iconPath: 'assets/icons/rocket.svg',
    representativeAge: 7,
    storyCount: '350+ Stories',
  ),
  AgeRange(
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

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: const _OnboardingScreenContent(),
    );
  }
}

class _OnboardingScreenContent extends StatefulWidget {
  const _OnboardingScreenContent();

  @override
  State<_OnboardingScreenContent> createState() =>
      __OnboardingScreenContentState();
}

class __OnboardingScreenContentState extends State<_OnboardingScreenContent> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final authVM = context.read<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildAgeStep(vm, context), _buildGenderStep(vm, context)],
              ),
            ),
            _buildBottomBar(vm, authVM, context),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStep(OnboardingViewModel vm, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/bear.svg',
                width: 56,
                height: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              localizations.onboarding_age_question,
              style: AppTextStyles.displayMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.onboarding_age_description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Column(
              children: ageRanges.map((range) {
                final isSelected = vm.selectedAge == range.representativeAge;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSelectionCard(
                    title: _getAgeTitle(range.representativeAge, localizations),
                    subtitle: _getAgeSubtitle(range.representativeAge, localizations),
                    badgeText: _getAgeStories(range.representativeAge, localizations),
                    leading: SvgPicture.asset(
                      range.iconPath,
                      width: 24,
                      height: 24,
                    ),
                    isSelected: isSelected,
                    onTap: () => vm.selectAge(range.representativeAge),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderStep(OnboardingViewModel vm, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isGirlSelected = vm.selectedGender == 'girl';
    final isBoySelected = vm.selectedGender == 'boy';
    final isNoneSelected =
        vm.selectedGender == 'unspecified' || vm.selectedGender == null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/kids_1.svg',
              width: MediaQuery.of(context).size.width * 0.5,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              localizations.onboarding_gender_question,
              style: AppTextStyles.displayMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.onboarding_gender_description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSelectionCard(
              title: localizations.gender_girl,
              subtitle: localizations.gender_girl_subtitle,
              leading: Icon(
                AppIcons.genderFemale,
                size: 24,
                color: isGirlSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              isSelected: isGirlSelected,
              onTap: () => vm.selectGender('girl'),
            ),
            const SizedBox(height: 16),
            _buildSelectionCard(
              title: localizations.gender_boy,
              subtitle: localizations.gender_boy_subtitle,
              leading: Icon(
                AppIcons.genderMale,
                size: 24,
                color: isBoySelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              isSelected: isBoySelected,
              onTap: () => vm.selectGender('boy'),
            ),
            const SizedBox(height: 16),
            _buildSelectionCard(
              title: localizations.gender_unspecified,
              subtitle: localizations.gender_unspecified_subtitle,
              leading: Icon(
                AppIcons.genderNeuter,
                size: 24,
                color: isNoneSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              isSelected: isNoneSelected,
              onTap: () => vm.selectGender('unspecified'),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              icon: Icon(AppIcons.info, size: 20, color: AppColors.primary),
              label: Text(
                localizations.onboarding_why_we_ask_button,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => _showWhyWeAskDialog(context),
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
    final isDark = AppColors.current == AppColors.darkScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade200),
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
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                if (leading != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: leading,
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badgeText,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isSelected
                      ? AppIcons.checkCircleFill
                      : AppIcons.checkCircleRegular,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade400),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWhyWeAskDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.onboarding_why_we_ask_title,
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.onboarding_why_we_ask_content,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localizations.onboarding_got_it, style: AppTextStyles.buttonLarge),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    OnboardingViewModel vm,
    AuthViewModel authVM,
    BuildContext context,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final isAgeStep = vm.currentStep == 0;
    final isNextDisabled = isAgeStep && vm.selectedAge == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          if (!isAgeStep)
            TextButton.icon(
              icon: Icon(
                AppIcons.arrowLeft,
                size: 18,
                color: AppColors.textSecondary,
              ),
              label: Text(
                localizations.onboarding_back,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: vm.isLoading
                  ? null
                  : () {
                      vm.prevStep();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: isNextDisabled || vm.isLoading
                ? null
                : () async {
                    if (isAgeStep) {
                      vm.nextStep();
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      final success = await vm.completeOnboarding(authVM);
                      if (success && context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(140, 54),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: vm.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAgeStep ? localizations.onboarding_continue : localizations.onboarding_complete,
                        style: AppTextStyles.buttonLarge,
                      ),
                      const SizedBox(width: 8),
                      Icon(AppIcons.arrowRight, size: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
