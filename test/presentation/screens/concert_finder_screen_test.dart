import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/data/datasources/supabase_concerts_datasource.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/entities/event_recommendation.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/location_provider.dart';
import 'package:vibra/presentation/providers/musical_dna_providers.dart';
import 'package:vibra/presentation/screens/explore/concert_finder_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_event_meta.dart';

class _Source extends Mock implements SupabaseConcertsDatasource {}

Event _event({String? currency, double? price = 35}) => Event(
  id: 'e1',
  externalId: 'x',
  source: 'ticketmaster',
  name: 'Utopia Tour',
  artistName: 'Travis Scott',
  venueName: 'Ippodromo',
  city: 'Milano',
  eventDate: DateTime.now().add(const Duration(days: 10)),
  priceMin: price,
  priceCurrency: currency,
  genres: const ['Hip-Hop/Rap'],
);

void main() {
  setUpAll(() => registerFallbackValue(const ConcertFilters()));

  test('reasons parse defensively; unknown codes are dropped', () {
    expect(
      EventReason.fromJson({'code': 'top_artist', 'artist': 'SZA', 'rank': 2}),
      isA<TopArtistEventReason>(),
    );
    expect(
      EventReason.fromJson({'code': 'top_artist', 'artist': 'SZA'}),
      isNull,
    );
    expect(EventReason.fromJson({'code': 'tickets_selling_fast'}), isNull);
  });

  test('filters only send what is set', () {
    expect(const ConcertFilters().toBody(), isEmpty);
    expect(
      const ConcertFilters(
        family: 'hip-hop',
        radiusKm: 25,
        priceMax: 60,
      ).toBody(),
      {'family': 'hip-hop', 'radius_km': 25, 'price_max': 60},
    );
  });

  testWidgets('prices appear only with a known currency', (tester) async {
    late String? withCurrency, withoutCurrency;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            withCurrency = vibraEventPriceLabel(
              context,
              _event(currency: 'USD'),
            );
            withoutCurrency = vibraEventPriceLabel(context, _event());
            return const SizedBox();
          },
        ),
      ),
    );
    expect(withCurrency, contains(r'$35'));
    expect(withoutCurrency, isNull);
  });

  testWidgets('finder: reasons, genre tag, saved flag; filters re-query', (
    tester,
  ) async {
    if (!AppConstants.spotifyEnabled) return;
    final source = _Source();
    when(
      () => source.recommend(
        filters: any(named: 'filters'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer(
      (_) async => ConcertRecommendations(
        origin: RecommendationOrigin.none,
        events: [
          RecommendedEvent(
            event: _event(currency: 'EUR'),
            relevance: 100,
            saved: true,
            families: const ['hip-hop'],
            reasons: const [
              TopArtistEventReason('Travis Scott', 1),
              GenreEventReason('trap', 40),
              SoonEventReason(10),
            ],
          ),
        ],
      ),
    );
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseConcertsDatasourceProvider.overrideWithValue(source),
          userLocationProvider.overrideWith((ref) async => UserLocation.milano),
          myMusicalDnaHistoryProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: ConcertFinderScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('You might enjoy these upcoming events.'), findsOneWidget);
    expect(
      find.text('Travis Scott is #1 in your top artists.'),
      findsOneWidget,
    );
    expect(find.text('Trap is 40% of your Musical DNA.'), findsOneWidget);
    expect(find.text('In 10 days.'), findsOneWidget);
    expect(find.text('Hip-Hop'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    // The browsing fallback is never sent as the user's position.
    verify(
      () => source.recommend(
        filters: const ConcertFilters(),
        latitude: null,
        longitude: null,
      ),
    ).called(1);
    expect(
      find.text('Turn on location to see distances and nearby events.'),
      findsOneWidget,
    );

    await tester.tap(find.text('25 km'));
    await tester.pumpAndSettle();
    verify(
      () => source.recommend(
        filters: const ConcertFilters(radiusKm: 25),
        latitude: null,
        longitude: null,
      ),
    ).called(1);
    await tester.tap(find.textContaining('Up to').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Only events with a published price in euros.'),
      findsOneWidget,
    );
  });
}
