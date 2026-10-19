import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra/core/services/cache_service.dart';
import 'package:vibra/core/utils/logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('support diagnostics redact bearer, query and JSON secrets', () {
    VibraLogger.error(
      'Bearer secretBearer access_token=secretAccess&x=1 '
      '"refresh_token":"secretRefresh" password=secretPassword',
    );
    final log = VibraLogger.supportLogs.last['message']!;
    for (final secret in [
      'secretBearer',
      'secretAccess',
      'secretRefresh',
      'secretPassword',
    ]) {
      expect(log, isNot(contains(secret)));
    }
  });
  test(
    'private cache migrates away from preferences and clears on logout',
    () async {
      SharedPreferences.setMockInitialValues({
        'CACHE_MUSIC_PROFILE_old': '{"private":true}',
      });
      await CacheService.initialize();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('CACHE_MUSIC_PROFILE_old'), false);
      final key = CacheService.musicProfileKey('alice');
      await CacheService.saveObject(key, {'private': true});
      expect(prefs.containsKey(key), false);
      expect(CacheService.getObject(key), {'private': true});
      expect(
        CacheService.getObject(CacheService.musicProfileKey('bob')),
        isNull,
      );
      await CacheService.clearAll();
      expect(CacheService.getObject(key), isNull);
    },
  );
}
