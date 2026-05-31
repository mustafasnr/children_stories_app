import 'package:children_stories/core/constants/supabase_constants.dart';
import 'package:children_stories/data/models/book_audio_model.dart';
import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/models/book_page_model.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/data/models/language_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Languages ───────────────────────────────────────────────────────────

  Future<List<Language>> getLanguages() async {
    final data = await _client
        .from('languages_with_story_count')
        .select()
        .order('sort_order');
    return (data as List).map((e) => Language.fromJson(e)).toList();
  }

  // ─── Categories (with translations) ──────────────────────────────────────

  Future<List<Category>> getCategoriesByLanguage(String languageCode) async {
    final data = await _client
        .from(SupabaseConstants.categoriesTable)
        .select('*, category_translations!inner(name)')
        .eq('category_translations.language_code', languageCode)
        .order('sort_order');
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  // ─── Books (with translations) ───────────────────────────────────────────

  Future<List<Book>> getBooksByLanguage(
    String languageCode, {
    int? categoryId,
    int? childAge,
    int limit = 10,
    int offset = 0,
  }) async {
    var query = _client
        .from(SupabaseConstants.booksTable)
        .select('*, book_translations!inner(title, description)')
        .eq('book_translations.language_code', languageCode)
        .eq('is_featured', false);
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (childAge != null) {
      query = query.lte('age_min', childAge).gte('age_max', childAge);
    }
    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return (data as List).map((e) => Book.fromJson(e)).toList();
  }

  Future<List<Book>> getFeaturedBooks(String languageCode, {int? childAge}) async {
    var query = _client
        .from(SupabaseConstants.booksTable)
        .select('*, book_translations!inner(title, description)')
        .eq('book_translations.language_code', languageCode)
        .eq('is_featured', true);
    if (childAge != null) {
      query = query.lte('age_min', childAge).gte('age_max', childAge);
    }
    final data = await query.limit(5);
    return (data as List).map((e) => Book.fromJson(e)).toList();
  }

  Future<Book?> getBookById(String id, String languageCode) async {
    final data = await _client
        .from(SupabaseConstants.booksTable)
        .select('*, book_translations!inner(title, description)')
        .eq('id', id)
        .eq('book_translations.language_code', languageCode)
        .maybeSingle();
    return data == null ? null : Book.fromJson(data);
  }

  // ─── Pages (with translations) ──────────────────────────────────────────

  Future<List<BookPage>> getBookPages(
      String bookId, String languageCode) async {
    final data = await _client
        .from(SupabaseConstants.pagesTable)
        .select('*, page_translations!inner(text_content, audio_seek_seconds)')
        .eq('book_id', bookId)
        .eq('page_translations.language_code', languageCode)
        .order('page_number');
    return (data as List).map((e) => BookPage.fromJson(e)).toList();
  }

  // ─── Audio ──────────────────────────────────────────────────────────────

  Future<BookAudio?> getBookAudio(String bookId, String languageCode) async {
    final data = await _client
        .from(SupabaseConstants.bookAudioTable)
        .select()
        .eq('book_id', bookId)
        .eq('language_code', languageCode)
        .maybeSingle();
    return data == null ? null : BookAudio.fromJson(data);
  }
}
