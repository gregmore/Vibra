import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/app.dart';
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

  testWidgets('localeStateProvider switches locale dynamically', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VibraApp(),
      ),
    );

    // Aspettiamo che l'app carichi il default locale
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(VibraApp));
    final container = ProviderScope.containerOf(context);

    // Default locale è null (sistema)
    expect(container.read(localeStateProvider), isNull);

    // Cambiamo a 'en'
    await container.read(localeStateProvider.notifier).setLocale('en');
    await tester.pumpAndSettle();

    expect(container.read(localeStateProvider), const Locale('en'));

    // Cambiamo a 'es'
    await container.read(localeStateProvider.notifier).setLocale('es');
    await tester.pumpAndSettle();

    expect(container.read(localeStateProvider), const Locale('es'));

    // Cambiamo a 'it'
    await container.read(localeStateProvider.notifier).setLocale('it');
    await tester.pumpAndSettle();

    expect(container.read(localeStateProvider), const Locale('it'));
  });
}
