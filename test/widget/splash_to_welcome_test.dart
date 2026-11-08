import 'package:vibra/core/constants/app_constants.dart';
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

  testWidgets('Splash opens Welcome without an artificial delay', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: VibraApp()));

    // Navigation starts on the first frame; only the route transition remains.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Welcome contiene il titolo della prima slide
    expect(
      find.text(
        AppConstants.spotifyEnabled
            ? 'Connetti i tuoi gusti'
            : 'La tua agenda live',
      ),
      findsOneWidget,
    );
  });
}
