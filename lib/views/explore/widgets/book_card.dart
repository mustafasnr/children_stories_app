import 'package:children_stories/app/theme/app_colors.dart';
import 'package:children_stories/app/theme/app_text_styles.dart';
import 'package:children_stories/data/models/book_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/book/${book.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover
              _buildCover(),
              const SizedBox(width: 14),
              // Info
              Expanded(child: _buildInfo(context)),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(20),
          ),
          child: SizedBox(
            width: 90,
            height: 120,
            child: book.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: book.coverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _gradientCover(),
                    errorWidget: (_, _, _) => _gradientCover(),
                  )
                : _gradientCover(),
          ),
        ),
        if (book.isPremium)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('✨', style: TextStyle(fontSize: 10)),
            ),
          ),
      ],
    );
  }

  Widget _gradientCover() => Container(
    decoration: BoxDecoration(gradient: AppColors.coverGradient(book.id)),
    child: Center(
      child: Text(
        book.title.isNotEmpty ? book.title[0] : '📖',
        style: const TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            style: AppTextStyles.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (book.description != null)
            Text(
              book.description!,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _tag(context, '👶 ${book.ageRange}'),
              _tag(context, '⏱ ${book.readTime}'),
              if (book.pageCount > 0)
                _tag(context, '📄 ${book.pageCount} pages'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: AppTextStyles.labelSmall),
  );
}
