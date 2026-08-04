import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra/presentation/screens/home/home_screen.dart';
import 'package:vibra/l10n/app_localizations.dart';
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

  testWidgets('HomeScreen mostra sezioni principali', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: HomeScreen(),
        ),
      ),
    );

    // Wait for the fade-in animations to finish settling
    await tester.pumpAndSettle();

    expect(find.text('Per Te'), findsOneWidget);
    // Gli altri header ('Vicino a Te', 'Trend') vengono mostrati solo se ci sono eventi
    // Il TextField della ricerca è stato rimosso dalla home.
  });
}
