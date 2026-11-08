import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/data/datasources/supabase_feed_datasource.dart';
import 'package:vibra/domain/entities/feed_post.dart';
import 'package:vibra/domain/entities/music_story.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/feed/feed_composer_screen.dart';
import 'package:vibra/presentation/screens/feed/feed_screen.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/presentation/widgets/common/vibra_state_views.dart';

class _Source extends Mock implements SupabaseFeedDatasource {}

const _album = StoryItem(
  provider: 'spotify',
  itemId: '2xLMifQCjDGFmkHkpNLD9h',
  title: 'Homogenic',
  subtitle: 'Björk · 1997',
  externalUrl: 'https://open.spotify.com/album/2xLMifQCjDGFmkHkpNLD9h',
);

FeedPost _post(
  String id, {
  String user = 'ana',
  FeedReason reason = FeedReason.genres,
  bool liked = false,
}) => FeedPost(
  id: id,
  userId: user,
  username: user,
  kind: FeedKind.review,
  itemType: FeedItemType.album,
  item: _album,
  body: 'A masterpiece',
  rating: 5,
  likeCount: liked ? 1 : 0,
  myReactions: liked ? const {feedLike} : const {},
  createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  reason: reason,
);

void main() {
  late _Source source;

  setUpAll(() {
    registerFallbackValue(FeedMode.forYou);
    registerFallbackValue(FeedKind.opinion);
  });

  setUp(() {
    source = _Source();
    when(() => source.currentUserId).thenReturn('me');
    when(
      () => source.feed(
        any(),
        before: any(named: 'before'),
        exclude: any(named: 'exclude'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((inv) async {
      final mode = inv.positionalArguments.first as FeedMode;
      return mode == FeedMode.forYou
          ? [_post('p1'), _post('p2', user: 'bo', reason: FeedReason.following)]
          : [_post('p3', user: 'cy', reason: FeedReason.chronological)];
    });
    when(() => source.markSeen(any())).thenAnswer((_) async {});
    when(() => source.toggleReaction(any(), any())).thenAnswer((_) async {});
    when(() => source.setBookmark(any(), any())).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseFeedDatasourceProvider.overrideWithValue(source)],
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

  testWidgets('For you shows why each post is there; chronological does not', (
    tester,
  ) async {
    await mount(tester, const FeedScreen());
    expect(find.text('Genres you love'), findsOneWidget);
    expect(find.text('You follow them'), findsOneWidget);
    expect(find.text('Homogenic'), findsNWidgets(2));
    expect(find.text('Music info and artwork from Spotify'), findsNWidgets(2));
    await tester.tap(find.text('Latest'));
    await tester.pumpAndSettle();
    expect(find.text('Genres you love'), findsNothing);
    verify(
      () => source.feed(
        FeedMode.latest,
        before: any(named: 'before'),
        exclude: any(named: 'exclude'),
        limit: any(named: 'limit'),
      ),
    ).called(1);
    // Shown posts are recorded (batched) to avoid repeating them.
    await tester.pump(const Duration(seconds: 4));
    verify(() => source.markSeen(any())).called(greaterThan(0));
  });

  testWidgets('like and bookmark update at once and call the server', (
    tester,
  ) async {
    await mount(tester, const FeedScreen());
    await tester.tap(find.byTooltip('Like').first);
    await tester.pump();
    verify(() => source.toggleReaction('p1', 'like')).called(1);
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byTooltip('Save').first);
    await tester.pump();
    verify(() => source.setBookmark('p1', true)).called(1);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('share sheet reposts with a comment', (tester) async {
    when(
      () => source.post(
        kind: any(named: 'kind'),
        sharedPostId: any(named: 'sharedPostId'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async {});
    await mount(tester, const FeedScreen());
    await tester.tap(find.byTooltip('Share').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Listen to this');
    await tester.tap(find.text('Share to your feed'));
    await tester.pumpAndSettle();
    verify(
      () => source.post(
        kind: FeedKind.share,
        sharedPostId: 'p1',
        body: 'Listen to this',
      ),
    ).called(1);
    expect(find.text('Shared to your feed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('post screen: comment and reply', (tester) async {
    when(() => source.post1('p1')).thenAnswer((_) async => _post('p1'));
    when(() => source.comments('p1')).thenAnswer(
      (_) async => [
        FeedComment(
          id: 'c1',
          authorId: 'bo',
          username: 'bo',
          body: 'Agreed',
          createdAt: DateTime.now(),
        ),
      ],
    );
    when(
      () => source.comment(any(), any(), parentId: any(named: 'parentId')),
    ).thenAnswer((_) async {});
    await mount(tester, const FeedPostScreen(postId: 'p1'));
    expect(find.text('Agreed'), findsOneWidget);
    await tester.tap(find.text('Reply'));
    await tester.pump();
    expect(find.text('Replying to bo'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Same');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    verify(() => source.comment('p1', 'Same', parentId: 'c1')).called(1);
  });

  testWidgets('composer: a review needs a rating and text', (tester) async {
    when(
      () => source.search(FeedItemType.album, 'homogenic'),
    ).thenAnswer((_) async => [_album]);
    when(
      () => source.post(
        kind: any(named: 'kind'),
        itemType: any(named: 'itemType'),
        spotifyItem: any(named: 'spotifyItem'),
        linkUrl: any(named: 'linkUrl'),
        linkTitle: any(named: 'linkTitle'),
        linkSubtitle: any(named: 'linkSubtitle'),
        mediaPath: any(named: 'mediaPath'),
        eventId: any(named: 'eventId'),
        body: any(named: 'body'),
        rating: any(named: 'rating'),
        everyone: any(named: 'everyone'),
        commentsEnabled: any(named: 'commentsEnabled'),
      ),
    ).thenAnswer((_) async {});
    await mount(tester, const FeedComposerScreen(initialKind: FeedKind.review));
    await tester.enterText(find.byType(TextField).first, 'homogenic');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Homogenic'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'A masterpiece');
    await tester.pump();
    final publish = find.text('Publish');
    await tester.ensureVisible(publish);
    await tester.tap(publish);
    await tester.pump();
    verifyNever(
      () => source.post(
        kind: any(named: 'kind'),
        itemType: any(named: 'itemType'),
        spotifyItem: any(named: 'spotifyItem'),
        body: any(named: 'body'),
        rating: any(named: 'rating'),
      ),
    );
    await tester.ensureVisible(find.byTooltip('4 stars'));
    await tester.tap(find.byTooltip('4 stars'));
    await tester.pump();
    await tester.ensureVisible(publish);
    await tester.tap(publish);
    await tester.pump();
    verify(
      () => source.post(
        kind: FeedKind.review,
        itemType: FeedItemType.album,
        spotifyItem: _album,
        linkUrl: null,
        linkTitle: null,
        linkSubtitle: null,
        mediaPath: null,
        eventId: null,
        body: 'A masterpiece',
        rating: 4,
        everyone: true,
        commentsEnabled: true,
      ),
    ).called(1);
  });

  // Acceptance criteria (docs/acceptance.md): error, offline and empty.
  group('states', () {
    testWidgets('offline: the offline state with Retry, never raw errors', (
      tester,
    ) async {
      when(
        () => source.feed(
          any(),
          before: any(named: 'before'),
          exclude: any(named: 'exclude'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const NetworkException(message: 'Failed host lookup'));
      await mount(tester, const FeedScreen());
      expect(find.byType(VibraErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.textContaining('NetworkException'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no data: the empty state, not a blank screen', (tester) async {
      when(
        () => source.feed(
          any(),
          before: any(named: 'before'),
          exclude: any(named: 'exclude'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => []);

      await mount(tester, const FeedScreen());
      expect(find.byType(VibraEmptyView), findsWidgets);
      expect(find.byType(VibraErrorView), findsNothing);
    });
  });
}
