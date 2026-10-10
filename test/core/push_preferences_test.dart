import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra/core/config/push_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('legacy opt-out is preserved once for the signed-in account', () async {
    SharedPreferences.setMockInitialValues({'push_enabled': false});
    final prefs = await SharedPreferences.getInstance();
    var writes = 0;
    await PushPreferences.migrateLegacyOptOut(
      prefs,
      'alice',
      () async => writes++,
    );
    expect(prefs.getBool(PushPreferences.key('alice')), false);
    expect(prefs.containsKey(PushPreferences.key('bob')), false);
    await PushPreferences.migrateLegacyOptOut(
      prefs,
      'alice',
      () async => writes++,
    );
    expect(writes, 1);
  });
  test(
    'an explicit account preference takes precedence over the legacy value',
    () async {
      SharedPreferences.setMockInitialValues({
        'push_enabled': false,
        'push_enabled_alice': true,
      });
      final prefs = await SharedPreferences.getInstance();
      await PushPreferences.migrateLegacyOptOut(
        prefs,
        'alice',
        () async => fail('Must preserve explicit preference'),
      );
      expect(prefs.getBool(PushPreferences.key('alice')), true);
    },
  );
  test('legacy opt-in never overrides the server consent', () async {
    SharedPreferences.setMockInitialValues({'push_enabled': true});
    final prefs = await SharedPreferences.getInstance();
    await PushPreferences.migrateLegacyOptOut(
      prefs,
      'alice',
      () async => fail('Must not write consent'),
    );
    expect(prefs.containsKey(PushPreferences.key('alice')), false);
  });
}
