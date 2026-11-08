import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/profile/music_genres_screen.dart';

class _Datasource extends Mock implements SupabaseDatasource {}

class _Social extends Mock implements SupabaseSocialDatasource {}

class _Client extends Mock implements SupabaseClient {}

class _Profile extends StateNotifier<AppUser> implements ProfileController {
  _Profile() : super(const AppUser(id: 'me', email: '', username: 'me'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  if (!AppConstants.spotifyEnabled) return;
  late _Social social;
  late _Datasource datasource;
  Map<String, int>? saved;

  setUp(() {
    social = _Social();
    datasource = _Datasource();
    final client = _Client();
    saved = null;
    when(() => datasource.client).thenReturn(client);
    // Consent lookup fails in tests → the switch stays off, nothing breaks.
    when(() => client.auth).thenThrow(StateError('no auth in tests'));
    when(
      () => social.getMyGenrePreferences(),
    ).thenAnswer((_) async => {'trap': 100, 'not-in-catalogue': 50});
    when(() => social.saveMyGenrePreferences(any())).thenAnswer((call) async {
      saved = Map<String, int>.from(call.positionalArguments.first as Map);
    });
    when(() => social.recomputeAffinity()).thenAnswer((_) async {});
    when(
      () => social.getAffinityFeed(limit: any(named: 'limit')),
    ).thenAnswer((_) async => []);
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseDatasourceProvider.overrideWithValue(datasource),
          supabaseSocialDatasourceProvider.overrideWithValue(social),
          myProfileProvider.overrideWith((ref) => _Profile()),
          matchedUsersProvider.overrideWith(
            (ref) => MatchedUsersController(ref),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: MusicGenresScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads picks, adjusts intensity, removes, searches and saves', (
    tester,
  ) async {
    await mount(tester);
    // Saved pick restored with its intensity; unknown keys are dropped.
    expect(find.text('Trap · Lo adoro'), findsOneWidget);
    expect(find.text('1 genere scelto'), findsOneWidget);

    // Tap cycles the intensity.
    await tester.tap(find.text('Trap · Lo adoro'));
    await tester.pump();
    expect(find.text('Trap · Mi piace'), findsOneWidget);

    // Search, then pick from the results.
    await tester.enterText(find.byType(TextField), 'neo');
    await tester.pump();
    expect(find.byKey(const ValueKey('genre-neo-soul')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('genre-neo-soul')));
    await tester.pump();
    expect(find.text('Neo Soul · Molto'), findsOneWidget);

    // Remove Trap with its delete button.
    await tester.tap(find.byTooltip('Rimuovi Trap'));
    await tester.pump();
    expect(find.text('Trap · Mi piace'), findsNothing);

    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(saved, {'neo-soul': 70});
    verify(() => social.recomputeAffinity()).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed save keeps the picks and shows an error', (
    tester,
  ) async {
    when(
      () => social.saveMyGenrePreferences(any()),
    ).thenThrow(Exception('offline'));
    await mount(tester);
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('Impossibile salvare i generi. Riprova.'), findsOneWidget);
    expect(find.text('Trap · Lo adoro'), findsOneWidget);
    verifyNever(() => social.recomputeAffinity());
  });
}
