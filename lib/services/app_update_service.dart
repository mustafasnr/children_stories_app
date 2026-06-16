import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUpdateResult {
  final String storeUrl;
  final bool isForce;

  AppUpdateResult({
    required this.storeUrl,
    required this.isForce,
  });
}

class AppUpdateService {
  AppUpdateService._();

  static final _client = Supabase.instance.client;

  /// Checks if an update is required or recommended.
  /// Returns the update result (store URL and whether it's forced) if an update is available, otherwise null.
  static Future<AppUpdateResult?> checkUpdate() async {
    try {
      // 1. Fetch configs from Supabase app_config table
      final response = await _client
          .from('app_config')
          .select('key, value');
      
      final configs = {
        for (var row in response as List)
          row['key'] as String: row['value'] as String
      };

      final String minVersionKey;
      final String latestVersionKey;
      final String storeUrlKey;

      if (defaultTargetPlatform == TargetPlatform.android) {
        minVersionKey = 'min_version_android';
        latestVersionKey = 'latest_version_android';
        storeUrlKey = 'store_url_android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        minVersionKey = 'min_version_ios';
        latestVersionKey = 'latest_version_ios';
        storeUrlKey = 'store_url_ios';
      } else {
        minVersionKey = 'min_version';
        latestVersionKey = 'latest_version';
        storeUrlKey = 'store_url';
      }

      final minVersionStr = configs[minVersionKey] ?? configs['min_version'];
      final latestVersionStr = configs[latestVersionKey] ?? configs['latest_version'];
      final storeUrl = configs[storeUrlKey] ?? configs['store_url'];

      if (storeUrl == null) {
        debugPrint('[AppUpdateService] Missing store_url ($storeUrlKey) in app_config');
        return null;
      }

      // 2. Read version from package_info_plus
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;

      // 3. Compare with version package
      final currentVersion = Version.parse(currentVersionStr);

      // 4. Check Force Update
      if (minVersionStr != null) {
        final minVersion = Version.parse(minVersionStr);
        debugPrint('[AppUpdateService] Current: $currentVersion, Min Required: $minVersion');
        if (currentVersion < minVersion) {
          return AppUpdateResult(storeUrl: storeUrl, isForce: true);
        }
      }

      // 5. Check Soft Update (Latest Version)
      if (latestVersionStr != null) {
        final latestVersion = Version.parse(latestVersionStr);
        debugPrint('[AppUpdateService] Current: $currentVersion, Latest Version: $latestVersion');
        if (currentVersion < latestVersion) {
          return AppUpdateResult(storeUrl: storeUrl, isForce: false);
        }
      }
    } catch (e) {
      // Offline or database not accessible: we proceed without forcing/notifying update to avoid bricking the app
      debugPrint('[AppUpdateService] Error checking update: $e');
    }
    return null;
  }
}
