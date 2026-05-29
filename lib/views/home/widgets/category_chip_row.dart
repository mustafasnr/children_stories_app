import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CategoryChipRow extends StatelessWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  String _translateCategory(BuildContext context, Category cat) {
    final localizations = AppLocalizations.of(context)!;
    switch (cat.id) {
      case 1:
        return localizations.category_1;
      case 2:
        return localizations.category_2;
      case 3:
        return localizations.category_3;
      case 4:
        return localizations.category_4;
      case 5:
        return localizations.category_5;
      default:
        return cat.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final cat = categories[index];
          // index 0 = "All" → categoryId null
          final catId = index == 0 ? null : cat.id;
          final isSelected = selectedCategoryId == catId;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textHint.withValues(alpha: 0.4),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSelected(catId),
                borderRadius: BorderRadius.circular(16),
                splashColor: (isSelected ? Colors.white : AppColors.primary)
                    .withValues(alpha: 0.15),
                highlightColor: (isSelected ? Colors.white : AppColors.primary)
                    .withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        _translateCategory(context, cat),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
