import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_music_stories_datasource.dart';
import 'package:vibra/domain/entities/music_story.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/stories/story_composer_screen.dart';
import 'package:vibra/presentation/screens/stories/story_settings_screen.dart';
import 'package:vibra/presentation/screens/stories/story_viewer_screen.dart';

class _Source extends Mock implements SupabaseMusicStoriesDatasource {}

const _album = StoryItem(
  provider: 'spotify',
  itemId: '2xLMifQCjDGFmkHkpNLD9h',
  title: 'Homogenic',
  subtitle: 'Björk · 1997',
  externalUrl: 'https://open.spotify.com/album/2xLMifQCjDGFmkHkpNLD9h',
);

MusicStory _story(
  String id,
  String user, {
  StoryKind kind = StoryKind.album,
  String? body,
  bool seen = false,
  bool replies = true,
  int? views,
}) => MusicStory(
  id: id,
  userId: user,
  username: user,
  kind: kind,
  item: kind.isMusic ? _album : null,
  body: body,
  allowReplies: replies,
  seen: seen,
  viewCount: views,
  replyCount: views == null ? null : 0,
  createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  expiresAt: DateTime.now().add(const Duration(hours: 22)),
);

void main() {
  late _Source source;

  setUpAll(() {
    registerFallbackValue(StoryKind.album);
  });

  setUp(() {
    source = _Source();
    when(() => source.currentUserId).thenReturn('me');
    when(() => source.markViewed(any())).thenAnswer((_) async {});
    when(() => source.toggleReaction(any(), any())).thenAnswer((_) async {});
    when(
      () => source.reply(any(), any(), recipientId: any(named: 'recipientId')),
    ).thenAnswer((_) async {});
    when(() => source.ring()).thenAnswer((_) async => const []);
    when(
      () => source.settings(),
    ).thenAnswer((_) async => const StorySettings());
  });

  Future<void> mount(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseMusicStoriesDatasourceProvider.overrideWithValue(source),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: home,
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await tester.pump();
    }
  }

  testWidgets('a viewer sees the story, it is marked viewed, and advances', (
    tester,
  ) async {
    when(() => source.storiesOf('ana')).thenAnswer(
      (_) async => [
        _story('s1', 'ana', seen: true),
        _story('s2', 'ana', kind: StoryKind.opinion, body: 'Vinyl > streaming'),
      ],
    );
    await mount(tester, const StoryViewerScreen(userIds: ['ana']));
    // Starts at the first unseen story.
    expect(find.text('Vinyl > streaming'), findsOneWidget);
    expect(find.text('MUSIC OPINION'), findsOneWidget);
    verify(() => source.markViewed('s2')).called(1);
    verifyNever(() => source.markViewed('s1'));
    // Back to the first (left third).
    await tester.tapAt(const Offset(60, 600));
    await tester.pump();
    expect(find.text('Homogenic'), findsOneWidget);
    expect(find.text('Listen on Spotify'), findsOneWidget);
    expect(find.text('Music info and artwork from Spotify'), findsOneWidget);
    // Plays on by itself.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(storyDuration);
    await tester.pump();
    expect(find.text('Vinyl > streaming'), findsOneWidget);
  });

  testWidgets('react and reply privately', (tester) async {
    when(
      () => source.storiesOf('ana'),
    ).thenAnswer((_) async => [_story('s1', 'ana')]);
    await mount(tester, const StoryViewerScreen(userIds: ['ana']));
    await tester.tap(find.text('🔥'));
    await tester.pump();
    verify(() => source.toggleReaction('s1', 'fire')).called(1);
    await tester.enterText(find.byType(TextField), 'Masterpiece');
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();
    verify(() => source.reply('s1', 'Masterpiece')).called(1);
    expect(find.text('Reply sent privately'), findsOneWidget);
  });

  testWidgets('replies off: no reply field', (tester) async {
    when(
      () => source.storiesOf('ana'),
    ).thenAnswer((_) async => [_story('s1', 'ana', replies: false)]);
    await mount(tester, const StoryViewerScreen(userIds: ['ana']));
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Replies are off for this story'), findsOneWidget);
  });

  testWidgets('the author sees views and replies, never marks a view', (
    tester,
  ) async {
    when(
      () => source.storiesOf('me'),
    ).thenAnswer((_) async => [_story('s1', 'me', views: 4)]);
    await mount(tester, const StoryViewerScreen(userIds: ['me']));
    expect(find.textContaining('Your story'), findsOneWidget);
    expect(find.text('4 views'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    verifyNever(() => source.markViewed(any()));
  });

  testWidgets('compose an opinion with the default audience', (tester) async {
    when(
      () => source.post(
        kind: any(named: 'kind'),
        spotifyItem: any(named: 'spotifyItem'),
        linkUrl: any(named: 'linkUrl'),
        linkTitle: any(named: 'linkTitle'),
        linkSubtitle: any(named: 'linkSubtitle'),
        mediaPath: any(named: 'mediaPath'),
        eventId: any(named: 'eventId'),
        body: any(named: 'body'),
        background: any(named: 'background'),
        everyone: any(named: 'everyone'),
        allowReplies: any(named: 'allowReplies'),
      ),
    ).thenAnswer((_) async {});
    await mount(
      tester,
      const StoryComposerScreen(initialKind: StoryKind.opinion),
    );
    await tester.pumpAndSettle();
    expect(find.text('Disappears after 24 hours.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Vinyl > streaming');
    await tester.pump();
    // The preview shows the text as viewers will see it.
    expect(find.text('Vinyl > streaming'), findsNWidgets(2));
    await tester.ensureVisible(find.text('Share story'));
    await tester.tap(find.text('Share story'));
    await tester.pump();
    verify(
      () => source.post(
        kind: StoryKind.opinion,
        spotifyItem: null,
        linkUrl: null,
        linkTitle: null,
        linkSubtitle: null,
        mediaPath: null,
        eventId: null,
        body: 'Vinyl > streaming',
        background: 'aurora',
        everyone: false,
        allowReplies: true,
      ),
    ).called(1);
  });

  testWidgets('search an album on Spotify and pick it', (tester) async {
    when(
      () => source.search(StoryKind.album, 'homogenic'),
    ).thenAnswer((_) async => [_album]);
    await mount(
      tester,
      const StoryComposerScreen(initialKind: StoryKind.album),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'homogenic');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Homogenic').last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.text('Music info and artwork from Spotify'), findsOneWidget);
  });

  testWidgets('hide stories from a connection', (tester) async {
    when(() => source.audience()).thenAnswer(
      (_) async => [const StoryPerson(userId: 'bo', username: 'bo')],
    );
    when(() => source.setHiddenFrom(any(), any())).thenAnswer((_) async {});
    await mount(tester, const StorySettingsScreen());
    await tester.pumpAndSettle();
    expect(find.text('Hide your stories from'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    verify(() => source.setHiddenFrom('bo', true)).called(1);
  });
}
