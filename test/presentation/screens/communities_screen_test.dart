import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_communities_datasource.dart';
import 'package:vibra/domain/entities/community.dart';
import 'package:vibra/domain/entities/musical_dna.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/l10n/app_localizations_en.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/musical_dna_providers.dart';
import 'package:vibra/presentation/screens/communities/communities_screen.dart';
import 'package:vibra/presentation/screens/communities/community_screen.dart';
import 'package:vibra/presentation/widgets/community_widgets.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseCommunitiesDatasource {}

const _trap = Community(
  id: 'c-trap',
  slug: 'trap-nation',
  name: 'Trap Nation',
  kind: CommunityKind.genre,
  genreKey: 'trap',
  genreFamily: 'hip-hop',
  isOfficial: true,
  memberCount: 120,
);
const _jazz = Community(
  id: 'c-jazz',
  slug: 'jazz-lounge',
  name: 'Jazz Lounge',
  kind: CommunityKind.genre,
  genreKey: 'jazz',
  genreFamily: 'jazz',
  isOfficial: true,
);
const _mine = Community(
  id: 'c-mine',
  slug: 'ug',
  name: 'Underground Rap',
  kind: CommunityKind.genre,
  genreKey: 'underground-hip-hop',
  genreFamily: 'hip-hop',
  myRole: CommunityRole.member,
);

final _dna = MusicalDna.fromJson({
  'families': [
    {'key': 'hip-hop', 'share': 1.0, 'percent': 100},
  ],
  'subgenres': [
    {'key': 'trap', 'family': 'hip-hop', 'share': 0.4, 'percent': 40},
  ],
  'artists': [
    {'key': 'id:1', 'name': 'Travis Scott'},
  ],
})!;

CommunityPost _post(String author, {bool held = false}) => CommunityPost(
  id: 'p-$author',
  communityId: _mine.id,
  author: CommunityAuthor(id: author, username: author),
  kind: CommunityPostKind.post,
  body: 'Hello from $author',
  createdAt: DateTime.utc(2026, 11, 9),
  reactions: const {'fire': 2},
  heldForReview: held,
);

void main() {
  late _Source source;

  setUp(() {
    source = _Source();
    when(
      () => source.communities(),
    ).thenAnswer((_) async => [_trap, _jazz, _mine]);
    when(() => source.join(any())).thenAnswer((_) async {});
    when(() => source.currentUserId).thenReturn('me');
    when(
      () => source.feed(any(), kind: any(named: 'kind')),
    ).thenAnswer((_) async => [_post('alex')]);
    when(() => source.events(any())).thenAnswer((_) async => []);
    when(() => source.members(any())).thenAnswer((_) async => []);
  });

  setUpAll(() => registerFallbackValue(CommunityPostKind.post));

  Future<void> mount(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseCommunitiesDatasourceProvider.overrideWithValue(source),
          myMusicalDnaHistoryProvider.overrideWith((ref) async => [_dna]),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hub: DNA recommendations with reasons, mine, explore, join', (
    tester,
  ) async {
    await mount(tester, const CommunitiesScreen());
    expect(
      find.text('Based on your musical profile, you might enjoy Trap Nation.'),
      findsOneWidget,
    );
    expect(find.text('Trap is 40% of your Musical DNA.'), findsOneWidget);
    expect(find.text('Start the Travis Scott community'), findsOneWidget);
    expect(find.text('Your communities'), findsOneWidget);
    expect(find.text('Underground Rap'), findsOneWidget);
    // Jazz is not in the DNA: offered only under Explore, never as "for you".
    expect(find.textContaining('you might enjoy Jazz Lounge'), findsNothing);
    await tester.tap(find.text('Join').first);
    await tester.pumpAndSettle();
    verify(() => source.join('c-trap')).called(1);
  });

  testWidgets('community: members post and react; non-members only read', (
    tester,
  ) async {
    await mount(tester, const CommunityScreen(communityId: 'c-mine'));
    expect(find.text('Hello from alex'), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);
    expect(find.text('🎧'), findsOneWidget); // all reactions offered

    await mount(tester, const CommunityScreen(communityId: 'c-trap'));
    expect(find.text('New post'), findsNothing);
    expect(find.text('Join to post, comment and react.'), findsWidgets);
    expect(find.text('🎧'), findsNothing); // only existing reactions shown
    expect(find.text('🔥'), findsOneWidget);
  });

  testWidgets('menus offer only what the role allows', (tester) async {
    Future<List<String>> items({required bool mine, required bool mod}) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ContentMenu(
              isMine: mine,
              canModerate: mod,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      final texts = [
        for (final w in tester.widgetList<Text>(
          find.descendant(
            of: find.byType(PopupMenuItem<ContentAction>),
            matching: find.byType(Text),
          ),
        ))
          w.data!,
      ];
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      return texts;
    }

    expect(await items(mine: true, mod: false), ['Delete']);
    expect(await items(mine: false, mod: false), ['Report', 'Block user']);
    expect(await items(mine: false, mod: true), [
      'Report',
      'Block user',
      'Remove (moderator)',
      'Ban from community',
    ]);
  });

  test('server errors become readable messages, never raw codes', () {
    final l10n = AppLocalizationsEn();
    expect(
      communityErrorText(l10n, Exception('PT429 Rate limit exceeded')),
      l10n.communitiesErrorRate,
    );
    expect(
      communityErrorText(l10n, Exception('duplicate_content')),
      l10n.communitiesErrorSpam,
    );
    expect(
      communityErrorText(l10n, Exception('community_banned')),
      l10n.communitiesErrorBanned,
    );
    expect(
      communityErrorText(l10n, Exception('community_post_daily_limit')),
      l10n.communitiesErrorLimit,
    );
    expect(communityErrorText(l10n, Exception('boom')), l10n.communitiesError);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.communities(),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester, const CommunitiesScreen());
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
