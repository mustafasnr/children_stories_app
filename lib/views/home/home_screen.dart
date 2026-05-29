import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:children_stories/views/home/widgets/book_card.dart';
import 'package:children_stories/views/home/widgets/category_chip_row.dart';
import 'package:children_stories/views/home/widgets/featured_book_card.dart';
import 'package:children_stories/views/home/widgets/language_bottom_sheet.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childAge = context.read<AuthViewModel>().profile?.childAge;
      context.read<HomeViewModel>().initialize(childAge: childAge);
      context.read<SubscriptionViewModel>().checkSubscriptionStatus();
    });
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
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  toolbarHeight: 70,
                  title: Text(
                    'Story Time',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  actions: [
                    if (vm.selectedLanguage != null)
                      TextButton.icon(
                        onPressed: () {
                          LanguageBottomSheet.show(
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
                    IconButton(
                      icon: Icon(
                        Icons.manage_accounts_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 26,
                      ),
                      onPressed: () => context.push('/profile'),
                    ),
                    const SizedBox(width: 8),
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
                            child: PageView.builder(
                              clipBehavior: Clip.none,
                              padEnds: false,
                              controller: PageController(viewportFraction: 0.9),
                              itemCount: vm.featuredBooks.length,
                              itemBuilder: (_, i) => Padding(
                                padding: EdgeInsets.only(
                                  right: i < vm.featuredBooks.length - 1
                                      ? 12
                                      : 0,
                                ),
                                child: FeaturedBookCard(
                                  book: vm.featuredBooks[i],
                                ),
                              ),
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
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => BookCard(book: vm.books[i]),
                        childCount: vm.books.length,
                      ),
                    ),
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
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[50]!;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            height: 200,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              height: 120,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(HomeViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              vm.error ?? '',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: vm.refresh,
              child: const Text('Try Again'),
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
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            localizations.no_stories_yet,
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.stories_coming_soon,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
