class SupabaseConstants {
  SupabaseConstants._();

  static const String url = 'https://vqukoqhisyrqdqrmoqpy.supabase.co';

  static const String anonKey =
      'sb_publishable_AmodbSpKE0xPjMAnzKcH5Q_Kmf8I3E1';

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
