import 'package:children_stories/data/models/book_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookmarkRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Book>> getBookmarkedBooks(String userId, String languageCode) async {
    final data = await _client
        .from('bookmarks')
        .select('books!inner(*, book_translations!inner(title, description))')
        .eq('user_id', userId)
        .eq('books.book_translations.language_code', languageCode);

    return (data as List).map((e) {
      final bookData = e['books'] as Map<String, dynamic>;
      return Book.fromJson(bookData);
    }).toList();
  }

  Future<void> addBookmark(String userId, String bookId) async {
    await _client.from('bookmarks').insert({
      'user_id': userId,
      'book_id': bookId,
    });
  }

  Future<void> removeBookmark(String userId, String bookId) async {
    await _client
        .from('bookmarks')
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
  }

  Future<bool> isBookmarked(String userId, String bookId) async {
    final data = await _client
        .from('bookmarks')
        .select('id')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();
    return data != null;
  }

  Future<void> migrateBookmarks(String oldUserId, String newUserId) async {
    try {
      final oldBookmarks = await _client
          .from('bookmarks')
          .select('book_id')
          .eq('user_id', oldUserId);

      if (oldBookmarks.isEmpty) return;

      final newBookmarks = await _client
          .from('bookmarks')
          .select('book_id')
          .eq('user_id', newUserId);

      final newBookIds = newBookmarks.map((e) => e['book_id'] as String).toSet();

      final inserts = oldBookmarks
          .map((e) => e['book_id'] as String)
          .where((id) => !newBookIds.contains(id))
          .map((id) => {
                'user_id': newUserId,
                'book_id': id,
              })
          .toList();

      if (inserts.isNotEmpty) {
        await _client.from('bookmarks').insert(inserts);
      }

      await _client.from('bookmarks').delete().eq('user_id', oldUserId);
    } catch (e) {
      debugPrint('[BookmarkRepo] migrateBookmarks error: $e');
    }
  }
}
