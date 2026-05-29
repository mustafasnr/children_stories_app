import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/views/home/widgets/category_chip_row.dart';
import 'package:children_stories/views/home/widgets/featured_book_card.dart';
import 'package:children_stories/views/home/widgets/language_selector.dart';
import 'package:children_stories/views/home/widgets/book_card.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: vm.refresh,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                if (vm.isLoading) ...[
                  SliverToBoxAdapter(child: _buildShimmer()),
                ] else if (vm.error != null) ...[
                  SliverFillRemaining(child: _buildError(vm)),
                ] else ...[
                  // Language tabs
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: LanguageSelector(
                        languages: vm.languages,
                        selectedIndex: vm.selectedLanguageIndex,
                        onSelected: vm.selectLanguage,
                      ),
                    ),
                  ),
                  // Featured
                  if (vm.featuredBooks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            child: Text(
                              '✨ Featured',
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
                            ? 'All Stories'
                            : vm.categories
                                  .firstWhere(
                                    (c) => c.id == vm.selectedCategoryId,
                                    orElse: () => vm.categories.first,
                                  )
                                  .name,
                        style: AppTextStyles.headlineSmall,
                      ),
                    ),
                  ),
                  // Book list
                  if (vm.books.isEmpty)
                    SliverToBoxAdapter(child: _buildEmpty())
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

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      toolbarHeight: 70,
      title: Text(
        'Story Time',
        style: AppTextStyles.displayMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.manage_accounts_rounded,
            color: AppColors.textPrimary,
            size: 26,
          ),
          onPressed: () => context.push('/profile'),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
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

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'No stories yet',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Stories for this language are coming soon!',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
