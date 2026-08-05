import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/settings_viewmodel.dart';
import 'package:children_stories/views/settings/widgets/preferences_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreferencesTile extends StatelessWidget {
  const PreferencesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinkColor = isDark ? const Color(0xFFF48FB1) : const Color(0xFFD81B60);
    final localizations = AppLocalizations.of(context)!;

    // Watch AuthViewModel to rebuild when preferences change
    final authVM = context.watch<AuthViewModel>();

    // Retrieve child age and gender with fallback
    final age = authVM.profile?.childAge ?? authVM.localAge;
    final gender = authVM.profile?.childGender ?? authVM.localGender;

    // Format display text
    String ageText = '';
    if (age != null) {
      if (age <= 5) {
        ageText = '2-5';
      } else if (age <= 9) {
        ageText = '6-9';
      } else {
        ageText = '10-12';
      }
    }

    String genderText = '';
    if (gender != null) {
      if (gender == 'girl') {
        genderText = localizations.gender_girl;
      } else if (gender == 'boy') {
        genderText = localizations.gender_boy;
      } else {
        genderText = localizations.preferences_all;
      }
    }

    String displayText = localizations.preferences_not_set;
    if (age != null) {
      final ageStr = localizations.preferences_age_format(ageText);
      if (genderText.isNotEmpty) {
        displayText = '$ageStr • $genderText';
      } else {
        displayText = ageStr;
      }
    } else if (genderText.isNotEmpty) {
      displayText = genderText;
    }

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
              color: pinkColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.face_rounded, color: pinkColor, size: 20),
          ),
          title: Text(
            localizations.preferences_title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayText,
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
            String? langCode;
            try {
              langCode = context.read<HomeViewModel>().selectedLanguage?.code;
            } catch (_) {}
            try {
              langCode ??= context.read<SettingsViewModel>().appLanguageCode;
            } catch (_) {}

            PreferencesBottomSheet.show(
              context,
              initialAge: age,
              initialGender: gender,
              languageCode: langCode,
            );
          },
        ),
      ),
    );
  }
}
