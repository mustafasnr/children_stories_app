// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language_name => 'English';

  @override
  String get app_language => 'App Language';

  @override
  String get select_language => 'Select Language';

  @override
  String get all_stories => 'All Stories';

  @override
  String get featured => '✨ Featured';

  @override
  String get coming_soon => 'Coming Soon';

  @override
  String get no_stories_yet => 'No stories yet';

  @override
  String get stories_coming_soon =>
      'Stories for this language are coming soon!';

  @override
  String get category_1 => 'All Stories';

  @override
  String get category_2 => 'Fairy Tales';

  @override
  String get category_3 => 'Adventure';

  @override
  String get category_4 => 'Animals';

  @override
  String get category_5 => 'Fantasy';
}
