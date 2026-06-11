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
  String get featured => 'Featured';

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

  @override
  String get login_title => 'Children Stories';

  @override
  String get login_subtitle => 'Magical stories for curious minds';

  @override
  String get login_by_continuing => 'By continuing you agree to our ';

  @override
  String get login_terms_of_service => 'Terms of Service';

  @override
  String get login_and => '\nand ';

  @override
  String get login_privacy_policy => 'Privacy Policy';

  @override
  String get login_agree_suffix => '.';

  @override
  String get login_get_started => 'Get Started';

  @override
  String get login_card_subtitle => 'Sign in to start your reading adventure';

  @override
  String get login_connect_google => 'Connect';

  @override
  String get login_continue_google => 'Continue';

  @override
  String get login_connect_apple => 'Connect';

  @override
  String get login_continue_apple => 'Continue';

  @override
  String get login_not_now => 'Not Now';

  @override
  String get login_continue_without_sign_in => 'Continue without signing in';

  @override
  String get login_google_key_mismatch_warning =>
      'Google sign-in is currently unavailable because development and release keys do not match.';

  @override
  String get onboarding_age_title_3 => '2 - 5 Years Old';

  @override
  String get onboarding_age_subtitle_3 =>
      'Picture books, lullabies & simple tales';

  @override
  String get onboarding_age_stories_3 => '150+ Stories';

  @override
  String get onboarding_age_title_7 => '6 - 9 Years Old';

  @override
  String get onboarding_age_subtitle_7 =>
      'Adventures, early readers & fairy tales';

  @override
  String get onboarding_age_stories_7 => '350+ Stories';

  @override
  String get onboarding_age_title_11 => '10 - 12 Years Old';

  @override
  String get onboarding_age_subtitle_11 => 'Chapter books, fantasy & mysteries';

  @override
  String get onboarding_age_stories_11 => '200+ Stories';

  @override
  String get onboarding_age_question => 'How old is the reader?';

  @override
  String get onboarding_age_description =>
      'We personalize the reading levels, vocabulary, and stories based on age.';

  @override
  String get onboarding_gender_question => 'Tell us about them';

  @override
  String get onboarding_gender_description =>
      'Help us tailor recommended stories for your child.';

  @override
  String get gender_girl => 'Girl';

  @override
  String get gender_girl_subtitle => 'Recommended stories for girls';

  @override
  String get gender_boy => 'Boy';

  @override
  String get gender_boy_subtitle => 'Recommended stories for boys';

  @override
  String get gender_unspecified => 'I don\'t want to specify';

  @override
  String get gender_unspecified_subtitle => 'Show stories for everyone';

  @override
  String get onboarding_why_we_ask_button =>
      'Why do we ask for this information?';

  @override
  String get onboarding_why_we_ask_title => 'Why We Ask';

  @override
  String get onboarding_why_we_ask_content =>
      'Every child is unique! By knowing their age and preferences, we can recommend stories that match their vocabulary level, interests, and developmental stage. Your data is kept private and used only to personalize their in-app experience.';

  @override
  String get onboarding_back => 'Back';

  @override
  String get onboarding_continue => 'Continue';

  @override
  String get onboarding_complete => 'Complete';

  @override
  String get onboarding_got_it => 'Got It!';

  @override
  String get preferences_title => 'Preferences';

  @override
  String get preferences_subtitle => 'Customize level & recommended stories';

  @override
  String get preferences_readers_age => 'Reader\'s Age';

  @override
  String get preferences_readers_gender => 'Reader\'s Gender';

  @override
  String get preferences_save_changes => 'Save Changes';

  @override
  String get preferences_update_success => 'Preferences updated successfully';

  @override
  String preferences_update_failed(String error) {
    return 'Failed to update preferences: $error';
  }

  @override
  String get preferences_not_set => 'Not Set';

  @override
  String get preferences_all => 'All';

  @override
  String preferences_age_format(String age) {
    return '$age Y/O';
  }

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_default_reader_name => 'Reader';

  @override
  String get settings_dark_mode => 'Dark Mode';

  @override
  String get settings_story_sounds => 'Story Sounds';

  @override
  String get settings_sign_out => 'Sign Out';

  @override
  String get settings_text_size => 'Text Size';

  @override
  String get settings_text_size_small => 'Small';

  @override
  String get settings_text_size_medium => 'Medium';

  @override
  String get settings_text_size_large => 'Large';

  @override
  String get settings_text_size_preview =>
      '\"Once upon a time, in a magical forest...\"';

  @override
  String get settings_anon_upgrade_title_library => 'Create Your Library';

  @override
  String get settings_anon_upgrade_desc_library =>
      'Save your favorite stories and access them anytime, anywhere.';

  @override
  String get settings_anon_upgrade_title_audio => 'Audio Narrations';

  @override
  String get settings_anon_upgrade_desc_audio =>
      'Listen to high-quality voiceovers and narrations.';

  @override
  String get settings_anon_upgrade_title_sync => 'Sync Across Devices';

  @override
  String get settings_anon_upgrade_desc_sync =>
      'Never lose your reading progress or saved stats.';

  @override
  String get settings_anon_upgrade_button => 'Sign In / Register';

  @override
  String get settings_manage_subscription => 'Manage Subscription';

  @override
  String settings_subscription_expires(String date) {
    return 'Expires: $date';
  }

  @override
  String get settings_subscription_signin_warning =>
      'Please sign in to access subscriptions. Tap to sign in.';

  @override
  String get settings_premium_active => 'Premium Active';

  @override
  String get settings_free_plan => 'Free Plan';

  @override
  String get settings_premium_active_desc => 'All stories & audio unlocked';

  @override
  String get settings_free_plan_desc => 'Upgrade to unlock everything';

  @override
  String get settings_premium_signin_warning =>
      'Please sign in first to purchase Premium! Tap to sign in.';

  @override
  String get settings_upgrade_button => 'Upgrade';

  @override
  String get explore_error_title => 'Oops! Something went wrong';

  @override
  String get explore_error_description =>
      'We couldn\'t load the stories. Please check your connection and try again.';

  @override
  String get explore_error_retry => 'Try Again';

  @override
  String get library_title => 'Library';

  @override
  String get library_guest_title => 'Sign in to save stories';

  @override
  String get library_guest_description =>
      'Keep track of your favorite stories and reading progress by creating an account.';

  @override
  String get library_guest_button => 'Sign In / Sign Up';

  @override
  String get library_empty_title => 'Your library is empty';

  @override
  String get library_empty_description =>
      'Tap the bookmark icon on any story to save it here for quick access.';

  @override
  String get library_error_description =>
      'We couldn\'t load your library. Please try again.';

  @override
  String get book_detail_not_found => 'Book not found.';

  @override
  String get book_detail_bookmark_signin_warning =>
      'Please sign in to bookmark stories. Tap to sign in.';

  @override
  String get book_detail_added_to_library => 'Added to library! Tap to view.';

  @override
  String get book_detail_removed_from_library => 'Removed from library';

  @override
  String get book_detail_badge_premium => 'Premium';

  @override
  String get book_detail_badge_featured => 'Featured';

  @override
  String get book_detail_stat_age => 'Age';

  @override
  String get book_detail_stat_time => 'Time';

  @override
  String get book_detail_stat_pages => 'Pages';

  @override
  String get book_detail_stat_audio => 'Audio';

  @override
  String get book_detail_about => 'About this Story';

  @override
  String get book_detail_premium_signin_warning =>
      'Please sign in first to access Premium content';

  @override
  String get book_detail_unlock_button => 'Unlock to Read Book';

  @override
  String get book_detail_read_button => 'Read Now';

  @override
  String get reader_font_size_title => 'Story Font Size';

  @override
  String reader_font_size_preview(int size) {
    return 'Preview Size: $size px';
  }

  @override
  String get reader_no_pages_title => 'Oops! No pages found';

  @override
  String get reader_no_pages_description =>
      'This story does not have any pages loaded yet. Please check back later or try reading another story.';

  @override
  String get reader_go_back => 'Go Back';

  @override
  String get badge_premium => 'Premium';

  @override
  String get badge_featured => 'Featured';

  @override
  String get explore_select_language_voice => 'Select Story Language & Voice';

  @override
  String explore_story_count(String count) {
    return '$count Stories';
  }

  @override
  String explore_book_age_range(int ageMin, int ageMax) {
    return '$ageMin–$ageMax yrs';
  }

  @override
  String explore_book_read_time(int minutes) {
    return '$minutes min read';
  }

  @override
  String get nav_explore => 'Explore';

  @override
  String get nav_library => 'Library';

  @override
  String get nav_settings => 'Settings';
}
