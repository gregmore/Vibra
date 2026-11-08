import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/theme/vibra_theme.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/profile/legal_support_screens.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://fake.supabase.co',
      publishableKey: 'fake',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  });
  testWidgets(
    'Guest can read legal information while private controls require login',
    (tester) async {
      final container = ProviderContainer();
      final router = container.read(routerProvider);
      router.go('/privacy-policy');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            theme: VibraTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('it'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      router.go('/terms-of-service');
      await tester.pumpAndSettle();
      expect(find.byType(TermsOfServiceScreen), findsOneWidget);
      router.go('/support');
      await tester.pumpAndSettle();
      expect(find.byType(SupportScreen), findsOneWidget);
      router.go('/privacy-controls');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/login');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      await tester.pump();
    },
  );
}
