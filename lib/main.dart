import 'package:children_stories/app/app.dart';
import 'package:children_stories/core/constants/app_constants.dart';
import 'package:children_stories/core/constants/supabase_constants.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize Adapty
  try {
    final config = AdaptyConfiguration(apiKey: AppConstants.adaptyPublicKey)
      ..withLogLevel(AdaptyLogLevel.verbose);
    await Adapty().activate(configuration: config);
  } catch (e) {
    debugPrint('[Adapty] init skipped: $e');
  }

  runApp(const ChildrenStoriesApp());
}
