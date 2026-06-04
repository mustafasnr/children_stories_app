import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/book_detail_viewmodel.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/auth_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/core/services/adapty_service.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late final BookDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = BookDetailViewModel();
    final langCode =
        context.read<HomeViewModel>().selectedLanguage?.code ?? 'en';
    final userId = context.read<AuthViewModel>().currentUser?.id;
    _vm.loadBook(widget.bookId, langCode, userId: userId);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subVM = context.watch<SubscriptionViewModel>();
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<BookDetailViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.book == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(
                  vm.error ?? 'Book not found.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          }
          final book = vm.book!;

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // Hero app bar with cover
                SliverAppBar(
                  expandedHeight: 340,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Color(0xFF1D1A26),
                      ),
                    ),
                  ),
                  actions: [
                    Consumer<BookDetailViewModel>(
                      builder: (context, vm, _) {
                        final authVM = context.read<AuthViewModel>();
                        final isBookmarked = vm.isBookmarked;

                        return GestureDetector(
                          onTap: () async {
                            if (authVM.isAnonymous) {
                              ToastService.showInfo(
                                'Please sign in to bookmark stories. Tap to sign in.',
                                onTap: () {
                                  context.push('/login?upgrade=true');
                                },
                              );
                            } else {
                              final userId = authVM.currentUser?.id;
                              if (userId != null) {
                                final wasBookmarked = vm.isBookmarked;
                                await vm.toggleBookmark(userId);
                                if (mounted) {
                                  if (!wasBookmarked) {
                                    ToastService.showSuccess(
                                      'Added to library! Tap to view.',
                                      onTap: () {
                                        context.go('/library');
                                      },
                                    );
                                  } else {
                                    ToastService.showInfo(
                                      'Removed from library',
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.all(10),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 18,
                              color: isBookmarked
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF1D1A26),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        book.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: book.coverUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.coverGradient(book.id),
                                  ),
                                ),
                                errorWidget: (_, _, _) =>
                                    _coverGradient(book.id),
                              )
                            : _coverGradient(book.id),
                        // Dark overlay gradient to make cover look integrated and text readable
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.25),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.35),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges row
                          Row(
                            children: [
                              if (book.isPremium)
                                _badge(
                                  '✨ Premium',
                                  AppColors.premium,
                                  Icons.star_rounded,
                                ),
                              if (book.isPremium && book.isFeatured)
                                const SizedBox(width: 8),
                              if (book.isFeatured)
                                _badge(
                                  '⭐ Featured',
                                  AppColors.primary,
                                  Icons.star_border_rounded,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            book.title,
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Stats/Meta row organized into clean cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Age',
                                  book.ageRange,
                                  Icons.face_rounded,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatCard(
                                  'Time',
                                  book.readTime,
                                  Icons.access_time_rounded,
                                  AppColors.accent,
                                ),
                              ),
                              if (book.pageCount > 0) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildStatCard(
                                    'Pages',
                                    '${book.pageCount}',
                                    Icons.menu_book_rounded,
                                    Colors.blue,
                                  ),
                                ),
                              ],
                              if (vm.hasAudio) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildStatCard(
                                    'Audio',
                                    vm.audio!.formattedDuration,
                                    Icons.headphones_rounded,
                                    AppColors.premium,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 28),
                          // About label
                          Text(
                            'About this Story',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (book.description != null)
                            Text(
                              book.description!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          const SizedBox(height: 36),
                          // Action buttons
                          _buildActionButtons(context, vm, subVM),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _coverGradient(String id) => Container(
    decoration: BoxDecoration(gradient: AppColors.coverGradient(id)),
  );

  Widget _badge(String label, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textHint.withValues(alpha: isDark ? 0.08 : 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    BookDetailViewModel vm,
    SubscriptionViewModel subVM,
  ) {
    final book = vm.book!;
    final isPremiumLocked = book.isPremium && !subVM.isPremium;

    if (isPremiumLocked) {
      return GestureDetector(
        onTap: () {
          final authVM = context.read<AuthViewModel>();
          if (authVM.isAnonymous) {
            ToastService.showInfo('Please sign in first to access Premium content');
            context.push('/login?upgrade=true');
          } else {
            AdaptyService.showPaywall(context);
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.premium.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Unlock to Read Book',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Otherwise, the user has access (free book, or premium user)
    return GestureDetector(
      onTap: () => context.push('/reader/${book.id}'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Read Now',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
