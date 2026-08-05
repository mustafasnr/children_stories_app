import 'package:children_stories/core/constants/supabase_constants.dart';
import 'package:children_stories/data/models/book_audio_model.dart';
import 'package:children_stories/data/models/book_model.dart';
import 'package:children_stories/data/models/book_page_model.dart';
import 'package:children_stories/data/models/category_model.dart';
import 'package:children_stories/data/models/language_model.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
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

  // ─── Story Counts by Age ──────────────────────────────────────────────────

  static final Map<String, Map<int, int>> _storyCountsByAgeCache = {};

  Future<Map<int, int>> getStoryCountsByAge({String? languageCode}) async {
    final cacheKey = languageCode ?? 'all';
    if (_storyCountsByAgeCache.containsKey(cacheKey)) {
      return _storyCountsByAgeCache[cacheKey]!;
    }
    try {
      var query = _client
          .from(SupabaseConstants.booksTable)
          .select('id, age_min, age_max');
      if (languageCode != null && languageCode.isNotEmpty) {
        query = _client
            .from(SupabaseConstants.booksTable)
            .select('id, age_min, age_max, book_translations!inner(language_code)')
            .eq('book_translations.language_code', languageCode);
      }
      final data = await query;
      final books = data as List<dynamic>;

      int count3 = 0;
      int count7 = 0;
      int count11 = 0;

      for (final b in books) {
        final ageMin = (b['age_min'] as num?)?.toInt() ?? 0;
        final ageMax = (b['age_max'] as num?)?.toInt() ?? 99;
        if (ageMin <= 3 && ageMax >= 3) count3++;
        if (ageMin <= 7 && ageMax >= 7) count7++;
        if (ageMin <= 11 && ageMax >= 11) count11++;
      }

      final result = {
        3: count3,
        7: count7,
        11: count11,
      };
      _storyCountsByAgeCache[cacheKey] = result;
      return result;
    } catch (e) {
      debugPrint('[BookRepository] error getting story counts by age: $e');
      return {3: 0, 7: 0, 11: 0};
    }
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

  Future<List<Book>> getFeaturedBooks(
    String languageCode, {
    int? childAge,
  }) async {
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

  Future<List<Book>> searchBooks(
    String languageCode, {
    required String queryText,
    List<int>? categoryIds,
    List<int>? childAges,
    bool? isPremium,
    int limit = 10,
    int offset = 0,
  }) async {
    var query = _client
        .from(SupabaseConstants.booksTable)
        .select('*, book_translations!inner(title, description)')
        .eq('book_translations.language_code', languageCode);

    final cleanQuery = queryText.trim();
    if (cleanQuery.isNotEmpty) {
      query = query.or(
        'title.ilike.%$cleanQuery%,description.ilike.%$cleanQuery%',
        referencedTable: 'book_translations',
      );
    }

    if (categoryIds != null && categoryIds.isNotEmpty) {
      query = query.inFilter('category_id', categoryIds);
    }
    if (childAges != null && childAges.isNotEmpty) {
      final ageFilters = childAges
          .map((age) => 'and(age_min.lte.$age,age_max.gte.$age)')
          .join(',');
      query = query.or(ageFilters);
    }
    if (isPremium != null) {
      query = query.eq('is_premium', isPremium);
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

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
    String bookId,
    String languageCode,
  ) async {
    final data = await _client
        .from(SupabaseConstants.pagesTable)
        .select('id, book_id, pages_data, created_at')
        .eq('book_id', bookId)
        .eq('language_code', languageCode)
        .maybeSingle();

    if (data == null) return [];

    final pagesList = data['pages_data'] as List<dynamic>? ?? [];
    final bookIdStr = data['book_id'] as String;
    final createdAtStr = data['created_at'] as String;

    return pagesList.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      map['book_id'] = bookIdStr;
      map['created_at'] = createdAtStr;
      return BookPage.fromJson(map);
    }).toList();
  }

  // ─── Audio ──────────────────────────────────────────────────────────────

  String _getStoragePath(String urlOrPath, String bucketName) {
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      final searchStr = '/$bucketName/';
      final idx = urlOrPath.indexOf(searchStr);
      if (idx != -1) {
        return Uri.decodeComponent(urlOrPath.substring(idx + searchStr.length));
      }
    }
    return urlOrPath;
  }

  Future<BookAudio?> getBookAudio(String bookId, String languageCode) async {
    final data = await _client
        .from(SupabaseConstants.bookAudioTable)
        .select()
        .eq('book_id', bookId)
        .eq('language_code', languageCode)
        .maybeSingle();
    if (data == null) return null;

    final mutableData = Map<String, dynamic>.from(data);
    try {
      final originalUrl = mutableData['audio_url'] as String;
      var path = _getStoragePath(originalUrl, SupabaseConstants.audioBucket);

      // Load the user's selected voice choice (default: 'kareem')
      final prefs = await SharedPreferences.getInstance();
      final selectedVoice = prefs.getString('selected_voice') ?? 'kareem';

      // Prepend selected voice prefix (e.g. "kareem_") to the audio filename in the storage path
      if (path.contains('/')) {
        final parts = path.split('/');
        final filename = parts.last;
        parts[parts.length - 1] = '${selectedVoice}_$filename';
        path = parts.join('/');
      } else {
        path = '${selectedVoice}_$path';
      }

      // Generate a signed URL valid for 20 minutes (1200 seconds)
      final signedUrl = await _client.storage
          .from(SupabaseConstants.audioBucket)
          .createSignedUrl(path, 1200);

      mutableData['audio_url'] = signedUrl;
    } catch (e) {
      debugPrint('[BookRepository] Failed to create signed URL for audio: $e');
    }

    return BookAudio.fromJson(mutableData);
  }
}
