import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/viewmodels/book_detail_viewmodel.dart';
import 'package:children_stories/viewmodels/home_viewmodel.dart';
import 'package:children_stories/viewmodels/subscription_viewmodel.dart';
import 'package:children_stories/core/services/adapty_service.dart';
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
    _vm.loadBook(widget.bookId, langCode);
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
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: book.coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: book.coverUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.coverGradient(book.id),
                              ),
                            ),
                            errorWidget: (_, _, _) => _coverGradient(book.id),
                          )
                        : _coverGradient(book.id),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badges row
                        Row(
                          children: [
                            if (book.isPremium)
                              _badge('✨ Premium', AppColors.premium),
                            if (book.isPremium) const SizedBox(width: 8),
                            if (book.isFeatured)
                              _badge('⭐ Featured', AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(book.title, style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 8),
                        // Meta row
                        Row(
                          children: [
                            _meta('👶', book.ageRange),
                            const SizedBox(width: 16),
                            _meta('⏱', book.readTime),
                            if (book.pageCount > 0) ...[
                              const SizedBox(width: 16),
                              _meta('📄', '${book.pageCount} pages'),
                            ],
                            if (vm.hasAudio) ...[
                              const SizedBox(width: 16),
                              _meta('🎧', vm.audio!.formattedDuration),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (book.description != null)
                          Text(
                            book.description!,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 32),
                        // Action buttons
                        _buildActionButtons(context, vm, subVM),
                        const SizedBox(height: 60),
                      ],
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

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );

  Widget _meta(String emoji, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 4),
      Text(text, style: AppTextStyles.labelMedium),
    ],
  );

  Widget _buildActionButtons(
    BuildContext context,
    BookDetailViewModel vm,
    SubscriptionViewModel subVM,
  ) {
    final book = vm.book!;
    final canRead = !book.isPremium || subVM.isPremium;

    return Column(
      children: [
        // Read button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              if (canRead) {
                context.push('/reader/${book.id}');
              } else {
                AdaptyService.showPaywall(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: canRead ? AppColors.primary : AppColors.textHint,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canRead ? Icons.menu_book_rounded : Icons.lock_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  canRead ? 'Read Now' : 'Unlock to Read',
                  style: AppTextStyles.buttonLarge,
                ),
              ],
            ),
          ),
        ),
        // Audio button (if available)
        if (vm.hasAudio) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                if (subVM.isPremium) {
                  context.push('/reader/${book.id}');
                } else {
                  AdaptyService.showPaywall(context);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    subVM.isPremium
                        ? Icons.headphones_rounded
                        : Icons.lock_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    subVM.isPremium
                        ? 'Listen – ${vm.audio!.formattedDuration}'
                        : '🎧 Audio (Premium)',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
