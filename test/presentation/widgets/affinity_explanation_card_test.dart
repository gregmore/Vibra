import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_affinity.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/widgets/affinity_explanation_card.dart';

Future<void> _mount(WidgetTester tester, AffinityExplanationCard card) =>
    tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: SingleChildScrollView(child: card)),
      ),
    );

void main() {
  testWidgets('Why you match: headline, reasons and only shared artists', (
    tester,
  ) async {
    final details = AffinityDetails.fromJson({
      'shared_artists': ['Future', 'Metro Boomin'],
      'shared_artist_count': 2,
      'reasons': [
        {
          'code': 'shared_families',
          'families': ['hip-hop'],
        },
        {
          'code': 'shared_subgenres',
          'subgenres': ['trap'],
        },
        {
          'code': 'shared_artists',
          'count': 2,
          'artists': ['Future', 'Metro Boomin'],
        },
      ],
    }, otherUserId: 'u2');
    await _mount(tester, AffinityExplanationCard(score: 89, details: details));
    expect(find.text('WHY YOU MATCH'), findsOneWidget);
    expect(find.text('You have 89% musical affinity.'), findsOneWidget);
    expect(find.text('You both mostly listen to Hip-Hop.'), findsOneWidget);
    expect(find.text('You share a love for Trap.'), findsOneWidget);
    expect(find.text('You share 2 favourite artists.'), findsOneWidget);
    expect(find.text('Future'), findsOneWidget);
    expect(find.text('Metro Boomin'), findsOneWidget);
  });

  testWidgets('no reasons from the server → nothing invented', (tester) async {
    await _mount(
      tester,
      const AffinityExplanationCard(score: 70, details: AffinityDetails.empty),
    );
    expect(find.text('WHY YOU MATCH'), findsNothing);
    expect(find.textContaining('musical affinity'), findsNothing);
  });
}
