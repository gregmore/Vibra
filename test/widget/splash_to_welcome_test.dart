import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra/app.dart';
import '../helpers/test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues(const {
      'user_selected_locale': 'it',
    });
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

  testWidgets('Splash naviga automaticamente a Welcome', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VibraApp()));

    // Splash presente
    await tester.pump();
    expect(find.text('Vibra'), findsWidgets);

    // Attende il delayed navigation (1800ms) + un frame
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    // Welcome contiene il titolo della prima slide
    expect(find.text('Connetti i tuoi gusti'), findsOneWidget);
  });
}

