import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/screens/profile/help_center_screen.dart';

void main() {
  testWidgets(
    'help categories and results remain valid after changing language',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final locale = ValueNotifier(const Locale('de'));
      addTearDown(locale.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: locale,
          builder: (_, selectedLocale, _) => MaterialApp(
            locale: selectedLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HelpCenterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final german = lookupAppLocalizations(const Locale('de'));
      final english = lookupAppLocalizations(const Locale('en'));
      expect(find.text(german.settingsHelpCenter), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, german.navEvents));
      await tester.pumpAndSettle();
      expect(find.text(german.helpEventsQuestion), findsOneWidget);
      expect(find.text(german.helpLoginQuestion), findsNothing);

      locale.value = const Locale('en');
      await tester.pumpAndSettle();
      expect(find.text(english.settingsHelpCenter), findsOneWidget);
      expect(find.text(english.helpEventsQuestion), findsOneWidget);
      expect(find.text(german.helpEventsQuestion), findsNothing);
      expect(find.text(english.helpLoginQuestion), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
