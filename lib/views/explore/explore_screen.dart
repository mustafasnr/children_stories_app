import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/views/explore/widgets/book_card.dart';
import 'package:children_stories/views/explore/widgets/category_chip_row.dart';
import 'package:children_stories/views/explore/widgets/featured_book_card.dart';
import 'package:children_stories/views/explore/widgets/story_language_bottom_sheet.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childAge = context.read<AuthViewModel>().profile?.childAge;
      context.read<HomeViewModel>().initialize(childAge: childAge);
      context.read<SubscriptionViewModel>().checkSubscriptionStatus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeViewModel>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: vm.refresh,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  toolbarHeight: 70,
                  title: Text(
                    'Children Stories',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  actions: [
                    if (vm.selectedLanguage != null)
                      TextButton.icon(
                        onPressed: () {
                          StoryLanguageBottomSheet.show(
                            context,
                            languages: vm.languages,
                            selectedIndex: vm.selectedLanguageIndex,
                            onSelected: vm.selectLanguage,
                          );
                        },
                        icon: CountryFlags.flag(
                          vm.selectedLanguage!.countryCode,
                          width: 24,
                          height: 18,
                          borderRadius: 4,
                        ),
                        label: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    const SizedBox(width: 16),
                  ],
                ),
                if (vm.isLoading) ...[
                  SliverToBoxAdapter(child: _buildShimmer(context)),
                ] else if (vm.error != null) ...[
                  SliverFillRemaining(child: _buildError(vm)),
                ] else ...[
                  // Featured
                  if (vm.featuredBooks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            child: Text(
                              localizations.featured,
                              style: AppTextStyles.headlineSmall,
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              clipBehavior: Clip.none,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 20),
                              itemCount: vm.featuredBooks.length,
                              itemBuilder: (context, i) {
                                final cardWidth =
                                    MediaQuery.of(context).size.width - 60;
                                return Container(
                                  width: cardWidth,
                                  margin: EdgeInsets.only(
                                    right: i < vm.featuredBooks.length - 1
                                        ? 12
                                        : 0,
                                  ),
                                  child: FeaturedBookCard(
                                    book: vm.featuredBooks[i],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  // Category chips
                  if (vm.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CategoryChipRow(
                          categories: vm.categories,
                          selectedCategoryId: vm.selectedCategoryId,
                          onSelected: vm.selectCategory,
                        ),
                      ),
                    ),
                  // Section label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Text(
                        vm.selectedCategoryId == null
                            ? localizations.all_stories
                            : (() {
                                final cat = vm.categories.firstWhere(
                                  (c) => c.id == vm.selectedCategoryId,
                                  orElse: () => vm.categories.first,
                                );
                                return _translateCategory(context, cat);
                              })(),
                        style: AppTextStyles.headlineSmall,
                      ),
                    ),
                  ),
                  // Book list
                  if (vm.books.isEmpty)
                    SliverToBoxAdapter(child: _buildEmpty(localizations))
                  else ...[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => BookCard(book: vm.books[i]),
                        childCount: vm.books.length,
                      ),
                    ),
                    if (vm.isLoadMoreRunning)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF3D3853)
        : const Color(0xFFE8E0F0);
    final highlightColor = isDark
        ? const Color(0xFF4D4866)
        : const Color(0xFFF5F0FF);
    final blockColor = isDark ? const Color(0xFF4A4460) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label placeholder
              Container(
                margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                height: 16,
                width: 100,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Featured card placeholder
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                height: 200,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              // Category chips placeholder
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 20),
                child: Row(
                  children: List.generate(
                    4,
                    (i) => Container(
                      margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
                      width: 70 + (i % 2) * 20,
                      height: 34,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              // Section label placeholder
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Book list item placeholders
              ...List.generate(
                4,
                (_) => Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  height: 110,
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(HomeViewModel vm) {
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
              'Oops! Something went wrong',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              vm.error ??
                  'We couldn\'t load the stories. Please check your connection and try again.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: vm.refresh,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildEmpty(AppLocalizations localizations) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 44,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.no_stories_yet,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              localizations.stories_coming_soon,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
