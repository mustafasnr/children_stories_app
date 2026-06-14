import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  SupabaseConstants._();

  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Table names
  static const String languagesTable = 'languages';
  static const String categoriesTable = 'categories';
  static const String categoryTranslationsTable = 'category_translations';
  static const String booksTable = 'books';
  static const String bookTranslationsTable = 'book_translations';
  static const String pagesTable = 'pages';
  static const String bookAudioTable = 'book_audio';
  static const String profilesTable = 'profiles';

  // Storage buckets
  static const String illustrationsBucket = 'illustrations';
  static const String audioBucket = 'audio';
  static const String coversBucket = 'covers';
}
