import 'package:shared_preferences/shared_preferences.dart';

/// Preserve a legacy local opt-out when moving to account-specific preferences.
class PushPreferences {
  PushPreferences._();

  static String key(String userId) => 'push_enabled_$userId';

  static Future<void> migrateLegacyOptOut(
    SharedPreferences prefs,
    String userId,
    Future<void> Function() persistOptOut,
  ) async {
    if (!prefs.containsKey(key(userId)) &&
        prefs.getBool('push_enabled') == false) {
      await persistOptOut();
      await prefs.setBool(key(userId), false);
    }
  }
}
