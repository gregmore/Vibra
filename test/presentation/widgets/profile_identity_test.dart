import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_profile_identity_datasource.dart';
import 'package:vibra/domain/entities/profile_identity.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/profile/profile_privacy_screen.dart';
import 'package:vibra/presentation/widgets/profile_identity_widgets.dart';

class _Source extends Mock implements SupabaseProfileIdentityDatasource {}

Map<String, dynamic> _json({
  bool me = false,
  List<String> hidden = const [],
}) => {
  'user_id': 'u1',
  'is_me': me,
  'relation': me ? 'me' : 'match',
  'username': 'ana',
  'display_name': 'Ana',
  'bio': 'Night drives and 808s',
  'member_since': '2026-01-10T00:00:00Z',
  'dna': {
    'families': [
      {'key': 'hip-hop', 'share': 0.6, 'percent': 60},
      {'key': 'electronic', 'share': 0.4, 'percent': 40},
    ],
    'subgenres': [
      {'key': 'trap', 'family': 'hip-hop', 'share': 0.5, 'percent': 50},
    ],
  },
  'sections': me ? {'saved_songs': 'private', 'events': 'connections'} : null,
  'hidden': hidden,
  'genres': ['underground-hip-hop'],
  'artists': [
    {'id': '0Y5tJX1MQlPlqiwlOH1tJY', 'name': 'Travis Scott'},
  ],
  'stats': {
    'followers': 12,
    'following': 3,
    'discoveries': 4,
    'posts': 2,
    'communities': 1,
    'genres': 5,
    'diversity': 61,
  },
  if (!hidden.contains('saved_songs'))
    'saved_songs': [
      {
        'title': 'SICKO MODE',
        'artist': 'Travis Scott',
        'external_url': 'https://open.spotify.com/track/x',
        'provider': 'spotify',
      },
    ],
  'playlists': [],
  'events': [
    {
      'id': 'e1',
      'name': 'Rap Night',
      'event_date': '2026-12-01T20:00:00Z',
      'city': 'Milano',
      'status': 'going',
    },
  ],
  'communities': [
    {'id': 'c1', 'name': 'Trap Nation', 'member_count': 12},
  ],
  'circles': [],
  'activity': [
    {
      'type': 'post',
      'id': 'p1',
      'kind': 'review',
      'title': 'Homogenic',
      'at': '2026-11-01T10:00:00Z',
    },
  ],
};

Widget _app(Widget child, _Source source) => ProviderScope(
  overrides: [
    supabaseProfileIdentityDatasourceProvider.overrideWithValue(source),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  late _Source source;
  setUp(() {
    source = _Source();
    when(() => source.currentUserId).thenReturn('u1');
    when(() => source.setLevel(any(), any())).thenAnswer((_) async {});
  });
  setUpAll(() {
    registerFallbackValue(ProfileSection.genres);
    registerFallbackValue(SectionLevel.public);
  });

  test('parses sections; a hidden section is null, an empty one is empty', () {
    final id = ProfileIdentity.fromJson(_json(hidden: ['saved_songs']))!;
    expect(id.savedSongs, isNull);
    expect(id.playlists, isEmpty);
    expect(id.hidden, {ProfileSection.savedSongs});
    expect(id.dna!.families.first.key, 'hip-hop');
    final mine = ProfileIdentity.fromJson(_json(me: true))!;
    expect(mine.levelOf(ProfileSection.savedSongs), SectionLevel.private);
    expect(mine.levelOf(ProfileSection.genres), SectionLevel.public);
  });

  testWidgets('a viewer sees allowed sections and a private-sections note', (
    tester,
  ) async {
    final id = ProfileIdentity.fromJson(_json(hidden: ['saved_songs']))!;
    await tester.pumpWidget(_app(IdentitySections(identity: id), source));
    for (final title in [
      'Favourite genres',
      'Favourite artists',
      'Musical statistics',
      'Upcoming events',
      'Musical activity',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    // A section title and a statistic.
    expect(find.text('Communities'), findsNWidgets(2));
    expect(find.text('Saved songs'), findsNothing);
    expect(find.text('Travis Scott'), findsOneWidget);
    expect(find.text('Trap Nation'), findsOneWidget);
    expect(find.text('Posted: Homogenic'), findsOneWidget);
    expect(
      find.text('Some sections of this profile are private.'),
      findsOneWidget,
    );
    // No visibility badges for a viewer.
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
  });

  testWidgets('the owner sees who can see each section', (tester) async {
    final id = ProfileIdentity.fromJson(_json(me: true))!;
    await tester.pumpWidget(_app(IdentitySections(identity: id), source));
    expect(find.text('Saved songs'), findsOneWidget);
    expect(find.bySemanticsLabel('Only me'), findsOneWidget);
    expect(find.bySemanticsLabel('Connections'), findsWidgets);
    expect(
      find.text('Some sections of this profile are private.'),
      findsNothing,
    );
  });

  testWidgets('sound signature names the top genres for screen readers', (
    tester,
  ) async {
    final id = ProfileIdentity.fromJson(_json())!;
    await tester.pumpWidget(
      _app(SoundSignatureAvatar(name: 'Ana', dna: id.dna), source),
    );
    expect(
      find.bySemanticsLabel('Ana, sound signature: Hip-Hop, Electronic'),
      findsOneWidget,
    );
  });

  testWidgets('privacy screen changes a section level', (tester) async {
    when(
      () => source.identity('u1'),
    ).thenAnswer((_) async => ProfileIdentity.fromJson(_json(me: true)));
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseProfileIdentityDatasourceProvider.overrideWithValue(source),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: ProfilePrivacyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Profile privacy'), findsOneWidget);
    // Favourite artists is the second section: make it connections-only.
    await tester.tap(find.text('Connections').at(1));
    await tester.pumpAndSettle();
    verify(
      () => source.setLevel(ProfileSection.artists, SectionLevel.connections),
    ).called(1);
  });
}
