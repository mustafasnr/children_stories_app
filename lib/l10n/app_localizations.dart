import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @language_name.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_name;

  /// No description provided for @app_language.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get app_language;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @all_stories.
  ///
  /// In en, this message translates to:
  /// **'All Stories'**
  String get all_stories;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming_soon;

  /// No description provided for @no_stories_yet.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get no_stories_yet;

  /// No description provided for @stories_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Stories for this language are coming soon!'**
  String get stories_coming_soon;

  /// No description provided for @category_1.
  ///
  /// In en, this message translates to:
  /// **'All Stories'**
  String get category_1;

  /// No description provided for @category_2.
  ///
  /// In en, this message translates to:
  /// **'Fairy Tales'**
  String get category_2;

  /// No description provided for @category_3.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get category_3;

  /// No description provided for @category_4.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get category_4;

  /// No description provided for @category_5.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get category_5;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Children Stories'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Magical stories for curious minds'**
  String get login_subtitle;

  /// No description provided for @login_by_continuing.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get login_by_continuing;

  /// No description provided for @login_terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get login_terms_of_service;

  /// No description provided for @login_and.
  ///
  /// In en, this message translates to:
  /// **'\nand '**
  String get login_and;

  /// No description provided for @login_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get login_privacy_policy;

  /// No description provided for @login_agree_suffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get login_agree_suffix;

  /// No description provided for @login_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get login_get_started;

  /// No description provided for @login_card_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to start your reading adventure'**
  String get login_card_subtitle;

  /// No description provided for @login_connect_google.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get login_connect_google;

  /// No description provided for @login_continue_google.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get login_continue_google;

  /// No description provided for @login_connect_apple.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get login_connect_apple;

  /// No description provided for @login_continue_apple.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get login_continue_apple;

  /// No description provided for @login_not_now.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get login_not_now;

  /// No description provided for @login_continue_without_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Continue without signing in'**
  String get login_continue_without_sign_in;

  /// No description provided for @login_google_key_mismatch_warning.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is currently unavailable because development and release keys do not match.'**
  String get login_google_key_mismatch_warning;

  /// No description provided for @onboarding_age_title_3.
  ///
  /// In en, this message translates to:
  /// **'2 - 5 Years Old'**
  String get onboarding_age_title_3;

  /// No description provided for @onboarding_age_subtitle_3.
  ///
  /// In en, this message translates to:
  /// **'Picture books, lullabies & simple tales'**
  String get onboarding_age_subtitle_3;

  /// No description provided for @onboarding_age_stories_3.
  ///
  /// In en, this message translates to:
  /// **'150+ Stories'**
  String get onboarding_age_stories_3;

  /// No description provided for @onboarding_age_title_7.
  ///
  /// In en, this message translates to:
  /// **'6 - 9 Years Old'**
  String get onboarding_age_title_7;

  /// No description provided for @onboarding_age_subtitle_7.
  ///
  /// In en, this message translates to:
  /// **'Adventures, early readers & fairy tales'**
  String get onboarding_age_subtitle_7;

  /// No description provided for @onboarding_age_stories_7.
  ///
  /// In en, this message translates to:
  /// **'350+ Stories'**
  String get onboarding_age_stories_7;

  /// No description provided for @onboarding_age_title_11.
  ///
  /// In en, this message translates to:
  /// **'10 - 12 Years Old'**
  String get onboarding_age_title_11;

  /// No description provided for @onboarding_age_subtitle_11.
  ///
  /// In en, this message translates to:
  /// **'Chapter books, fantasy & mysteries'**
  String get onboarding_age_subtitle_11;

  /// No description provided for @onboarding_age_stories_11.
  ///
  /// In en, this message translates to:
  /// **'200+ Stories'**
  String get onboarding_age_stories_11;

  /// No description provided for @onboarding_age_question.
  ///
  /// In en, this message translates to:
  /// **'How old is the reader?'**
  String get onboarding_age_question;

  /// No description provided for @onboarding_age_description.
  ///
  /// In en, this message translates to:
  /// **'We personalize the reading levels, vocabulary, and stories based on age.'**
  String get onboarding_age_description;

  /// No description provided for @onboarding_gender_question.
  ///
  /// In en, this message translates to:
  /// **'Tell us about them'**
  String get onboarding_gender_question;

  /// No description provided for @onboarding_gender_description.
  ///
  /// In en, this message translates to:
  /// **'Help us tailor recommended stories for your child.'**
  String get onboarding_gender_description;

  /// No description provided for @gender_girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get gender_girl;

  /// No description provided for @gender_girl_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended stories for girls'**
  String get gender_girl_subtitle;

  /// No description provided for @gender_boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get gender_boy;

  /// No description provided for @gender_boy_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended stories for boys'**
  String get gender_boy_subtitle;

  /// No description provided for @gender_unspecified.
  ///
  /// In en, this message translates to:
  /// **'I don\'t want to specify'**
  String get gender_unspecified;

  /// No description provided for @gender_unspecified_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Show stories for everyone'**
  String get gender_unspecified_subtitle;

  /// No description provided for @onboarding_why_we_ask_button.
  ///
  /// In en, this message translates to:
  /// **'Why do we ask for this information?'**
  String get onboarding_why_we_ask_button;

  /// No description provided for @onboarding_why_we_ask_title.
  ///
  /// In en, this message translates to:
  /// **'Why We Ask'**
  String get onboarding_why_we_ask_title;

  /// No description provided for @onboarding_why_we_ask_content.
  ///
  /// In en, this message translates to:
  /// **'Every child is unique! By knowing their age and preferences, we can recommend stories that match their vocabulary level, interests, and developmental stage. Your data is kept private and used only to personalize their in-app experience.'**
  String get onboarding_why_we_ask_content;

  /// No description provided for @onboarding_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboarding_back;

  /// No description provided for @onboarding_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboarding_continue;

  /// No description provided for @onboarding_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get onboarding_complete;

  /// No description provided for @onboarding_got_it.
  ///
  /// In en, this message translates to:
  /// **'Got It!'**
  String get onboarding_got_it;

  /// No description provided for @preferences_title.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences_title;

  /// No description provided for @preferences_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize level & recommended stories'**
  String get preferences_subtitle;

  /// No description provided for @preferences_readers_age.
  ///
  /// In en, this message translates to:
  /// **'Reader\'s Age'**
  String get preferences_readers_age;

  /// No description provided for @preferences_readers_gender.
  ///
  /// In en, this message translates to:
  /// **'Reader\'s Gender'**
  String get preferences_readers_gender;

  /// No description provided for @preferences_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get preferences_save_changes;

  /// No description provided for @preferences_update_success.
  ///
  /// In en, this message translates to:
  /// **'Preferences updated successfully'**
  String get preferences_update_success;

  /// No description provided for @preferences_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update preferences: {error}'**
  String preferences_update_failed(String error);

  /// No description provided for @preferences_not_set.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get preferences_not_set;

  /// No description provided for @preferences_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get preferences_all;

  /// No description provided for @preferences_age_format.
  ///
  /// In en, this message translates to:
  /// **'{age} Y/O'**
  String preferences_age_format(String age);

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_default_reader_name.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get settings_default_reader_name;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_story_sounds.
  ///
  /// In en, this message translates to:
  /// **'Story Sounds'**
  String get settings_story_sounds;

  /// No description provided for @settings_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settings_sign_out;

  /// No description provided for @settings_text_size.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get settings_text_size;

  /// No description provided for @settings_text_size_small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settings_text_size_small;

  /// No description provided for @settings_text_size_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settings_text_size_medium;

  /// No description provided for @settings_text_size_large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settings_text_size_large;

  /// No description provided for @settings_text_size_preview.
  ///
  /// In en, this message translates to:
  /// **'\"Once upon a time, in a magical forest...\"'**
  String get settings_text_size_preview;

  /// No description provided for @settings_anon_upgrade_title_library.
  ///
  /// In en, this message translates to:
  /// **'Create Your Library'**
  String get settings_anon_upgrade_title_library;

  /// No description provided for @settings_anon_upgrade_desc_library.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite stories and access them anytime, anywhere.'**
  String get settings_anon_upgrade_desc_library;

  /// No description provided for @settings_anon_upgrade_title_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio Narrations'**
  String get settings_anon_upgrade_title_audio;

  /// No description provided for @settings_anon_upgrade_desc_audio.
  ///
  /// In en, this message translates to:
  /// **'Listen to high-quality voiceovers and narrations.'**
  String get settings_anon_upgrade_desc_audio;

  /// No description provided for @settings_anon_upgrade_title_sync.
  ///
  /// In en, this message translates to:
  /// **'Sync Across Devices'**
  String get settings_anon_upgrade_title_sync;

  /// No description provided for @settings_anon_upgrade_desc_sync.
  ///
  /// In en, this message translates to:
  /// **'Never lose your reading progress or saved stats.'**
  String get settings_anon_upgrade_desc_sync;

  /// No description provided for @settings_anon_upgrade_button.
  ///
  /// In en, this message translates to:
  /// **'Sign In / Register'**
  String get settings_anon_upgrade_button;

  /// No description provided for @settings_manage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get settings_manage_subscription;

  /// No description provided for @settings_subscription_expires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String settings_subscription_expires(String date);

  /// No description provided for @settings_subscription_signin_warning.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to access subscriptions. Tap to sign in.'**
  String get settings_subscription_signin_warning;

  /// No description provided for @settings_premium_active.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get settings_premium_active;

  /// No description provided for @settings_free_plan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get settings_free_plan;

  /// No description provided for @settings_premium_active_desc.
  ///
  /// In en, this message translates to:
  /// **'All stories & audio unlocked'**
  String get settings_premium_active_desc;

  /// No description provided for @settings_free_plan_desc.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock everything'**
  String get settings_free_plan_desc;

  /// No description provided for @settings_premium_signin_warning.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first to purchase Premium! Tap to sign in.'**
  String get settings_premium_signin_warning;

  /// No description provided for @settings_upgrade_button.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get settings_upgrade_button;

  /// No description provided for @explore_error_title.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get explore_error_title;

  /// No description provided for @explore_error_description.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the stories. Please check your connection and try again.'**
  String get explore_error_description;

  /// No description provided for @explore_error_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get explore_error_retry;

  /// No description provided for @library_title.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library_title;

  /// No description provided for @library_guest_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save stories'**
  String get library_guest_title;

  /// No description provided for @library_guest_description.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your favorite stories and reading progress by creating an account.'**
  String get library_guest_description;

  /// No description provided for @library_guest_button.
  ///
  /// In en, this message translates to:
  /// **'Sign In / Sign Up'**
  String get library_guest_button;

  /// No description provided for @library_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty'**
  String get library_empty_title;

  /// No description provided for @library_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon on any story to save it here for quick access.'**
  String get library_empty_description;

  /// No description provided for @library_error_description.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your library. Please try again.'**
  String get library_error_description;

  /// No description provided for @book_detail_not_found.
  ///
  /// In en, this message translates to:
  /// **'Book not found.'**
  String get book_detail_not_found;

  /// No description provided for @book_detail_bookmark_signin_warning.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to bookmark stories. Tap to sign in.'**
  String get book_detail_bookmark_signin_warning;

  /// No description provided for @book_detail_added_to_library.
  ///
  /// In en, this message translates to:
  /// **'Added to library! Tap to view.'**
  String get book_detail_added_to_library;

  /// No description provided for @book_detail_removed_from_library.
  ///
  /// In en, this message translates to:
  /// **'Removed from library'**
  String get book_detail_removed_from_library;

  /// No description provided for @book_detail_badge_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get book_detail_badge_premium;

  /// No description provided for @book_detail_badge_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get book_detail_badge_featured;

  /// No description provided for @book_detail_stat_age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get book_detail_stat_age;

  /// No description provided for @book_detail_stat_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get book_detail_stat_time;

  /// No description provided for @book_detail_stat_pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get book_detail_stat_pages;

  /// No description provided for @book_detail_stat_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get book_detail_stat_audio;

  /// No description provided for @book_detail_about.
  ///
  /// In en, this message translates to:
  /// **'About this Story'**
  String get book_detail_about;

  /// No description provided for @book_detail_premium_signin_warning.
  ///
  /// In en, this message translates to:
  /// **'Please sign in first to access Premium content'**
  String get book_detail_premium_signin_warning;

  /// No description provided for @book_detail_unlock_button.
  ///
  /// In en, this message translates to:
  /// **'Unlock to Read Book'**
  String get book_detail_unlock_button;

  /// No description provided for @book_detail_read_button.
  ///
  /// In en, this message translates to:
  /// **'Read Now'**
  String get book_detail_read_button;

  /// No description provided for @reader_font_size_title.
  ///
  /// In en, this message translates to:
  /// **'Story Font Size'**
  String get reader_font_size_title;

  /// No description provided for @reader_font_size_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview Size: {size} px'**
  String reader_font_size_preview(int size);

  /// No description provided for @reader_no_pages_title.
  ///
  /// In en, this message translates to:
  /// **'Oops! No pages found'**
  String get reader_no_pages_title;

  /// No description provided for @reader_no_pages_description.
  ///
  /// In en, this message translates to:
  /// **'This story does not have any pages loaded yet. Please check back later or try reading another story.'**
  String get reader_no_pages_description;

  /// No description provided for @reader_go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get reader_go_back;

  /// No description provided for @badge_premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get badge_premium;

  /// No description provided for @badge_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get badge_featured;

  /// No description provided for @explore_select_language_voice.
  ///
  /// In en, this message translates to:
  /// **'Select Story Language & Voice'**
  String get explore_select_language_voice;

  /// No description provided for @explore_story_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Stories'**
  String explore_story_count(String count);

  /// No description provided for @explore_book_age_range.
  ///
  /// In en, this message translates to:
  /// **'{ageMin}–{ageMax} yrs'**
  String explore_book_age_range(int ageMin, int ageMax);

  /// No description provided for @explore_book_read_time.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String explore_book_read_time(int minutes);

  /// No description provided for @nav_explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get nav_explore;

  /// No description provided for @nav_library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get nav_library;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
