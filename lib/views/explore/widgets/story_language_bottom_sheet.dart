import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/core/constants/app_icons.dart';
import 'package:children_stories/core/utils/story_count_formatter.dart';
import 'package:children_stories/data/models/language_model.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryLanguageBottomSheet extends StatefulWidget {
  final List<Language> languages;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const StoryLanguageBottomSheet({
    super.key,
    required this.languages,
    required this.selectedIndex,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Language> languages,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    return showModalBottomSheet<void>(
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
  State<StoryLanguageBottomSheet> createState() =>
      _StoryLanguageBottomSheetState();
}

class _StoryLanguageBottomSheetState extends State<StoryLanguageBottomSheet> {
  bool _isReady = false;
  String _selectedVoice = 'kareem';

  @override
  void initState() {
    super.initState();
    _loadVoiceSelection();
    // Delay rendering of SVG flags to ensure the slide-up animation is completely smooth
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });
  }

  Future<void> _loadVoiceSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final voice = prefs.getString('selected_voice') ?? 'kareem';
      if (mounted) {
        setState(() {
          _selectedVoice = voice;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
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
            AppLocalizations.of(context)!.explore_select_language_voice,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),

          // Narrator Voice Selection Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildVoiceCard(
                    'kareem',
                    'Kareem',
                    'assets/icons/bear.svg',
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVoiceCard(
                    'emma',
                    'Emma',
                    'assets/icons/magic.svg',
                    isDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: AppColors.textHint.withValues(alpha: 0.15),
              thickness: 1.2,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),

          // Stories Language Selection List
          Expanded(
            child: !_isReady
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: widget.languages.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSkeletonItem(isDark),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: widget.languages.length,
                    itemBuilder: (context, index) {
                      final lang = widget.languages[index];
                      final isSelected = index == widget.selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
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
                                widget.onSelected(index);
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
                                    CountryFlag.fromCountryCode(
                                      lang.countryCode,
                                      theme: const ImageTheme(
                                        width: 30,
                                        height: 22,
                                        shape: RoundedRectangle(4),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              lang.name,
                                              style: AppTextStyles.titleMedium
                                                  .copyWith(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w800
                                                        : FontWeight.w600,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                        .withValues(alpha: 0.15)
                                                  : (isDark
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.08,
                                                              )
                                                        : AppColors
                                                              .surfaceVariant),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!.explore_story_count(formatStoryCount(lang.storyCount)),
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : AppColors
                                                              .textSecondary,
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
                                                ? Colors.white.withValues(
                                                    alpha: 0.25,
                                                  )
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

  Widget _buildVoiceCard(String id, String name, String svgPath, bool isDark) {
    final isSelected = _selectedVoice == id;
    return Container(
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
          onTap: () async {
            setState(() {
              _selectedVoice = id;
            });
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('selected_voice', id);
            } catch (_) {}
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    svgPath,
                    colorFilter: ColorFilter.mode(
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontSize: 15,
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
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonItem(bool isDark) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 22,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 90,
            height: 14,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
