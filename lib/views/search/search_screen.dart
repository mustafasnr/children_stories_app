// ignore_for_file: deprecated_member_use
import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/search_viewmodel.dart';
import 'package:children_stories/views/explore/widgets/book_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  String _lastLanguageCode = '';

  // Temporary drawer states
  final Set<int> _tempCategoryIds = {};
  final Set<int> _tempAges = {};
  bool? _tempIsPremium;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_onScroll);

    // Initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = context.read<HomeViewModel>();
      final langCode = homeVM.selectedLanguage?.code ?? 'en';
      _lastLanguageCode = langCode;
      context.read<SearchViewModel>().search(_controller.text, langCode, forceLoadingState: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final homeVM = context.read<HomeViewModel>();
      final langCode = homeVM.selectedLanguage?.code ?? 'en';
      context.read<SearchViewModel>().loadNextPage(langCode);
    }
  }

  void _performSearch(String query) {
    _focusNode.unfocus();
    final homeVM = context.read<HomeViewModel>();
    final langCode = homeVM.selectedLanguage?.code ?? 'en';
    context.read<SearchViewModel>().search(query, langCode);
  }

  void _openFilterDrawer() {
    final vm = context.read<SearchViewModel>();
    setState(() {
      _tempCategoryIds.clear();
      _tempCategoryIds.addAll(vm.selectedCategoryIds);
      _tempAges.clear();
      _tempAges.addAll(vm.selectedAges);
      _tempIsPremium = vm.selectedIsPremium;
    });
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<HomeViewModel>();
    final langCode = homeVM.selectedLanguage?.code ?? 'en';
    final vm = context.watch<SearchViewModel>();

    // Rerun search if the language changed in the explore/main view
    if (_lastLanguageCode != langCode) {
      _lastLanguageCode = langCode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SearchViewModel>().search(_controller.text, langCode, forceLoadingState: true);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildFilterDrawer(context, vm, langCode),
      drawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Button
            _buildSearchHeader(context, vm),
            // Active Filter Chips
            _buildActiveFiltersRow(context, vm, langCode),
            // Results List
            Expanded(
              child: Consumer<SearchViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return _buildShimmer(context);
                  }

                  if (vm.error != null) {
                    return _buildErrorState(context, vm, langCode);
                  }

                  if (vm.searchResults.isEmpty) {
                    return _buildEmptyState(context, vm, langCode);
                  }

                  return RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () => vm.search(_controller.text, langCode, forceLoadingState: false),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: vm.searchResults.length + (vm.isLoadMoreRunning ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == vm.searchResults.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return BookCard(book: vm.searchResults[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, SearchViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: _buildSearchTextField(context, vm),
          ),
          const SizedBox(width: 12),
          _buildFilterButton(context, vm),
        ],
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context, SearchViewModel vm) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: _performSearch,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: localizations.search_hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.textHint,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: vm.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear_rounded, color: AppColors.textHint, size: 20),
                        onPressed: () {
                          _controller.clear();
                          setState(() {});
                          _performSearch('');
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                      onPressed: () => _performSearch(_controller.text),
                    ),
                  ],
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (val) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, SearchViewModel vm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeCount = vm.selectedCategoryIds.length + vm.selectedAges.length + (vm.selectedIsPremium != null ? 1 : 0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: _openFilterDrawer,
            tooltip: 'Filters',
            padding: const EdgeInsets.all(14),
            iconSize: 24,
          ),
        ),
        if (activeCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                '$activeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveFiltersRow(BuildContext context, SearchViewModel vm, String langCode) {
    if (!vm.hasActiveFilters) return const SizedBox.shrink();

    final localizations = AppLocalizations.of(context)!;
    final list = <Widget>[];

    // Categories
    for (final catId in vm.selectedCategoryIds) {
      final cat = vm.categories.firstWhere(
        (c) => c.id == catId,
        orElse: () => Category(id: 0, name: '', slug: '', sortOrder: 0),
      );
      if (cat.name.isNotEmpty) {
        list.add(_buildActiveFilterChip(
          context: context,
          label: _translateCategory(context, cat),
          onDelete: () {
            vm.toggleCategory(catId);
            vm.search(_controller.text, langCode, forceLoadingState: true);
          },
        ));
      }
    }

    // Ages
    for (final age in vm.selectedAges) {
      list.add(_buildActiveFilterChip(
        context: context,
        label: _getAgeFilterLabel(context, age),
        onDelete: () {
          vm.toggleAge(age);
          vm.search(_controller.text, langCode, forceLoadingState: true);
        },
      ));
    }

    // Type
    if (vm.selectedIsPremium != null) {
      list.add(_buildActiveFilterChip(
        context: context,
        label: vm.selectedIsPremium! ? localizations.filter_premium : localizations.filter_free,
        onDelete: () {
          vm.setSelectedIsPremium(null);
          vm.search(_controller.text, langCode, forceLoadingState: true);
        },
      ));
    }

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length + 1,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == list.length) {
            return TextButton(
              onPressed: () => vm.clearFilters(langCode),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                localizations.filter_clear,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }
          return list[index];
        },
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required BuildContext context,
    required String label,
    required VoidCallback onDelete,
  }) {
    return GestureDetector(
      onTap: onDelete,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext context, SearchViewModel vm, String langCode) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  localizations.filter_title,
                  style: AppTextStyles.headlineLarge,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),
            // Scrollable Content
            Expanded(
              child: Theme(
                // Theme override to remove horizontal line dividers inside ExpansionTile expansion
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    // Categories
                    ExpansionTile(
                      title: Text(
                        localizations.filter_category,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: EdgeInsets.zero,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      children: vm.categories.map((cat) {
                        final isChecked = _tempCategoryIds.contains(cat.id);
                        return CheckboxListTile(
                          value: isChecked,
                          title: Text(
                            _translateCategory(context, cat),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isChecked ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          activeColor: AppColors.primary,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                _tempCategoryIds.add(cat.id);
                              } else {
                                _tempCategoryIds.remove(cat.id);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          dense: true,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    // Age Groups
                    ExpansionTile(
                      title: Text(
                        localizations.filter_age,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: EdgeInsets.zero,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      children: [3, 7, 11].map((age) {
                        final isChecked = _tempAges.contains(age);
                        return CheckboxListTile(
                          value: isChecked,
                          title: Text(
                            _getAgeFilterLabel(context, age),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isChecked ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          activeColor: AppColors.primary,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                _tempAges.add(age);
                              } else {
                                _tempAges.remove(age);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          dense: true,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    // Story Type
                    ExpansionTile(
                      title: Text(
                        localizations.filter_type,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: EdgeInsets.zero,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      children: [
                        (null, localizations.filter_all),
                        (false, localizations.filter_free),
                        (true, localizations.filter_premium),
                      ].map((option) {
                        final val = option.$1;
                        final label = option.$2;
                        final isSelected = _tempIsPremium == val;
                        return RadioListTile<bool?>(
                          value: val,
                          groupValue: _tempIsPremium,
                          title: Text(
                            label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          activeColor: AppColors.primary,
                          onChanged: (bool? value) {
                            setState(() {
                              _tempIsPremium = value;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          dense: true,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            // Footer Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    vm.setFilters(
                      categoryIds: _tempCategoryIds,
                      ages: _tempAges,
                      isPremium: _tempIsPremium,
                      languageCode: langCode,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(localizations.filter_apply),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAgeFilterLabel(BuildContext context, int age) {
    final localizations = AppLocalizations.of(context)!;
    switch (age) {
      case 3:
        return localizations.search_age_group_3;
      case 7:
        return localizations.search_age_group_7;
      case 11:
        return localizations.search_age_group_11;
      default:
        return '$age yrs';
    }
  }

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

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF3D3853) : const Color(0xFFE8E0F0);
    final highlightColor = isDark ? const Color(0xFF4D4866) : const Color(0xFFF5F0FF);
    final blockColor = isDark ? const Color(0xFF4A4460) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, index) => Container(
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          height: 125,
          decoration: BoxDecoration(
            color: blockColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SearchViewModel vm, String langCode) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 42,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.explore_error_title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              vm.error ?? localizations.explore_error_description,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => vm.search(_controller.text, langCode, forceLoadingState: true),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(localizations.explore_error_retry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, SearchViewModel vm, String langCode) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.search_no_results,
              style: AppTextStyles.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              localizations.search_no_results_desc,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (vm.hasActiveFilters) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => vm.clearFilters(langCode),
                icon: const Icon(Icons.filter_list_off_rounded, size: 20),
                label: Text(localizations.filter_clear),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
