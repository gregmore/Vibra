import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import '../helpers/test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues(const {});
    await Supabase.initialize(
      url: 'https://fake.supabase.co',
      publishableKey: 'fakeAnonKey',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  test('localeStateProvider switches locale dynamically', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Default locale è null (sistema)
    expect(container.read(localeStateProvider), isNull);

    // Cambiamo a 'en'
    await container.read(localeStateProvider.notifier).setLocale('en');
    expect(container.read(localeStateProvider), const Locale('en'));

    // Cambiamo a 'es'
    await container.read(localeStateProvider.notifier).setLocale('es');
    expect(container.read(localeStateProvider), const Locale('es'));

    // Cambiamo a 'it'
    await container.read(localeStateProvider.notifier).setLocale('it');
    expect(container.read(localeStateProvider), const Locale('it'));
  });
}
