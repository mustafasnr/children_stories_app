import 'package:children_stories/app/app.dart';
import 'package:children_stories/core/constants/app_constants.dart';
import 'package:children_stories/core/constants/supabase_constants.dart';
import 'package:children_stories/core/services/toast_service.dart';
import 'package:children_stories/services/app_update_service.dart';
import 'package:children_stories/widgets/force_update_dialog.dart';
import 'package:children_stories/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting();

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
    publishableKey: SupabaseConstants.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Initialize Adapty
  try {
    final config = AdaptyConfiguration(apiKey: AppConstants.adaptyPublicKey)
      ..withLogLevel(AdaptyLogLevel.verbose)
      ..withGoogleAdvertisingIdCollectionDisabled(true);
    await Adapty().activate(configuration: config);
  } catch (e) {
    debugPrint('[Adapty] init skipped: $e');
  }

  runApp(const RestartWidget(child: ChildrenStoriesApp()));

  // Check for app updates
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final updateResult = await AppUpdateService.checkUpdate();
    if (updateResult != null) {
      final context = ToastService.navigatorKey.currentContext;
      if (context != null && context.mounted) {
        if (updateResult.isForce) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ForceUpdateDialog(storeUrl: updateResult.storeUrl),
          );
        } else {
          final localizations = AppLocalizations.of(context);
          final toastMessage = localizations?.update_optional_toast ??
              'A new update is available. Tap here to update!';
          ToastService.showInfo(
            toastMessage,
            onTap: () async {
              final uri = Uri.parse(updateResult.storeUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          );
        }
      }
    }
  });
}
