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
        height:
            125, // Fixed height for performance, replacing costly IntrinsicHeight
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
    );
  }

  Widget _buildCover() {
    return SizedBox(
      width: 90,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            child: book.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: book.coverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _gradientCover(),
                    errorWidget: (_, _, _) => _gradientCover(),
                  )
                : _gradientCover(),
          ),
          if (book.isPremium)
            Positioned(
              top: 8,
              left: 8,
              child: _premiumBadge(),
            ),
          if (book.isFeatured)
            Positioned(
              top: book.isPremium ? 28 : 8,
              left: 8,
              child: _featuredBadge(),
            ),
        ],
      ),
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
    final ageRangeText = '${book.ageMin}-${book.ageMax}';
    final readTimeText = '${book.readTimeMinutes}';
    final pageCountText = '${book.pageCount}';

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _tag(context, Icons.child_care_rounded, ageRangeText),
              _tag(context, Icons.schedule_rounded, readTimeText),
              if (book.pageCount > 0)
                _tag(context, Icons.menu_book_rounded, pageCountText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(
            alpha: isDark ? 0.3 : 0.1,
          ),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFFBBF24), // Yellowish/Amber
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Text(
      'PREMIUM',
      style: TextStyle(
        fontSize: 7.5,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E1B4B),
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _featuredBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFD1FAE5), // Mint Green
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: const Color(0xFFA7F3D0),
        width: 0.8,
      ),
    ),
    child: const Text(
      'FEATURED',
      style: TextStyle(
        fontSize: 7.5,
        fontWeight: FontWeight.w900,
        color: Color(0xFF065F46),
        letterSpacing: 0.3,
      ),
    ),
  );
}
