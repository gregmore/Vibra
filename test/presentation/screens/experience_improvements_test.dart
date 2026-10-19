import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/domain/entities/direct_message.dart';
import 'package:vibra/domain/entities/direct_message_permission.dart';
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/domain/repositories/social_repository.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/direct_message_permission_provider.dart';
import 'package:vibra/presentation/providers/public_users_provider.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/screens/home/home_screen.dart';
import 'package:vibra/presentation/screens/social/chat_screen.dart';
import 'package:vibra/presentation/screens/social/discover_users_screen.dart';

import '../../helpers/test_http_overrides.dart';

class _Repository extends Mock implements SocialRepository {}

class _Conversations extends StateNotifier<List<ConversationSummary>>
    implements ConversationsController {
  _Conversations() : super([]);
  @override
  Future<void> refresh() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Requests extends StateNotifier<List<Friendship>>
    implements PendingFriendshipsController {
  _Requests() : super([]);
  @override
  Future<void> refresh() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Profile extends StateNotifier<AppUser> implements ProfileController {
  _Profile() : super(const AppUser(id: 'me', email: '', username: 'greg'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Feed extends StateNotifier<List<Event>> implements EventsFeedController {
  _Feed() : super([]);
  int refreshes = 0;
  @override
  Future<void> refresh() async {
    refreshes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
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

  Widget app(Widget screen) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('it'),
    home: screen,
  );

  Future<void> mountChat(WidgetTester tester, _Repository repository) async {
    when(
      () => repository.markMessagesAsRead(otherUserId: 'other'),
    ).thenAnswer((_) async {});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          streamConversationUseCaseProvider.overrideWithValue(
            StreamConversationUseCase(repository),
          ),
          sendDirectMessageUseCaseProvider.overrideWithValue(
            SendDirectMessageUseCase(repository),
          ),
          markMessagesAsReadUseCaseProvider.overrideWithValue(
            MarkMessagesAsReadUseCase(repository),
          ),
          conversationsProvider.overrideWith((ref) => _Conversations()),
          friendsProvider.overrideWithValue([]),
          pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
          directMessagePermissionProvider.overrideWith(
            (ref, id) async => DirectMessagePermission.allowed,
          ),
        ],
        child: app(
          const ChatScreen(otherUserId: 'other', otherDisplayName: 'Laura'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('Failed send preserves original message and the newer draft', (
    tester,
  ) async {
    final repo = _Repository();
    final pending = Completer<DirectMessage>();
    when(
      () => repo.streamMessagesWith(otherUserId: 'other'),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => repo.sendMessage(receiverId: 'other', content: 'Primo messaggio'),
    ).thenAnswer((_) => pending.future);
    await mountChat(tester, repo);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton && widget.tooltip == 'Invia messaggio',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'Primo messaggio');
    await tester.pump();
    await tester.tap(find.byTooltip('Invia messaggio'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Nuova bozza');
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton && widget.tooltip == 'Invia messaggio',
            ),
          )
          .onPressed,
      isNull,
    );
    pending.completeError(Exception('offline'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Primo messaggio\n\nNuova bozza',
    );
    verify(
      () => repo.sendMessage(receiverId: 'other', content: 'Primo messaggio'),
    ).called(1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Realtime snapshots retain pending sends and reconcile the server message',
    (tester) async {
      final repo = _Repository();
      final snapshots = StreamController<List<DirectMessage>>();
      final pending = Completer<DirectMessage>();
      when(
        () => repo.streamMessagesWith(otherUserId: 'other'),
      ).thenAnswer((_) => snapshots.stream);
      when(
        () => repo.sendMessage(receiverId: 'other', content: 'In attesa'),
      ).thenAnswer((_) => pending.future);
      await mountChat(tester, repo);
      snapshots.add([]);
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'In attesa');
      await tester.pump();
      await tester.tap(find.byTooltip('Invia messaggio'));
      await tester.pump();
      snapshots.add([]);
      await tester.pump();
      expect(find.text('In attesa'), findsOneWidget);
      final sent = DirectMessage(
        id: 'server',
        senderId: '',
        receiverId: 'other',
        content: 'In attesa',
        createdAt: DateTime.now(),
      );
      snapshots.add([sent]);
      await tester.pump();
      pending.complete(sent);
      await tester.pumpAndSettle();
      expect(find.text('In attesa'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(snapshots.hasListener, isFalse);
      unawaited(snapshots.close());
      await tester.pump();
    },
  );

  testWidgets(
    'Meetup response sends a real message without discarding the draft',
    (tester) async {
      final repo = _Repository();
      when(() => repo.streamMessagesWith(otherUserId: 'other')).thenAnswer(
        (_) => Stream.value([
          DirectMessage(
            id: 'proposal',
            senderId: 'other',
            receiverId: '',
            content: 'Davanti al palco alle 20',
            messageType: 'meetup_proposal',
            createdAt: DateTime.now(),
          ),
        ]),
      );
      when(
        () => repo.sendMessage(
          receiverId: 'other',
          content: 'Ci sto! Davanti al palco alle 20',
        ),
      ).thenAnswer(
        (_) async => DirectMessage(
          id: 'reply',
          senderId: '',
          receiverId: 'other',
          content: 'Ci sto! Davanti al palco alle 20',
          createdAt: DateTime.now(),
        ),
      );
      await mountChat(tester, repo);
      await tester.enterText(find.byType(TextField), 'La mia bozza');
      await tester.pump();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ChatScreen)),
      )!;
      await tester.ensureVisible(find.text(l10n.chatMeetupAccept));
      await tester.tap(find.text(l10n.chatMeetupAccept));
      await tester.pumpAndSettle();
      verify(
        () => repo.sendMessage(
          receiverId: 'other',
          content: 'Ci sto! Davanti al palco alle 20',
        ),
      ).called(1);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'La mia bozza',
      );
      expect(find.text('Ci sto! Davanti al palco alle 20'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'An earlier send cannot unlock a newer send after changing chats',
    (tester) async {
      final repo = _Repository();
      final recipient = ValueNotifier('other');
      final first = Completer<DirectMessage>();
      final current = Completer<DirectMessage>();
      addTearDown(recipient.dispose);
      when(
        () => repo.streamMessagesWith(otherUserId: 'other'),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => repo.streamMessagesWith(otherUserId: 'second'),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => repo.sendMessage(receiverId: 'other', content: 'Old send'),
      ).thenAnswer((_) => first.future);
      when(
        () => repo.sendMessage(receiverId: 'other', content: 'Current send'),
      ).thenAnswer((_) => current.future);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            streamConversationUseCaseProvider.overrideWithValue(
              StreamConversationUseCase(repo),
            ),
            sendDirectMessageUseCaseProvider.overrideWithValue(
              SendDirectMessageUseCase(repo),
            ),
            conversationsProvider.overrideWith((ref) => _Conversations()),
            friendsProvider.overrideWithValue([]),
            pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
            directMessagePermissionProvider.overrideWith(
              (ref, id) async => DirectMessagePermission.allowed,
            ),
          ],
          child: app(
            ValueListenableBuilder<String>(
              valueListenable: recipient,
              builder: (context, id, _) =>
                  ChatScreen(otherUserId: id, otherDisplayName: id),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField), 'Old send');
      await tester.pump();
      await tester.tap(find.byTooltip('Invia messaggio'));
      await tester.pump();
      recipient.value = 'second';
      await tester.pump();
      recipient.value = 'other';
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Current send');
      await tester.pump();
      await tester.tap(find.byTooltip('Invia messaggio'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Latest draft');
      await tester.pump();
      first.completeError(StateError('old failure'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Latest draft',
      );
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'Invia messaggio',
              ),
            )
            .onPressed,
        isNull,
      );
      current.complete(
        DirectMessage(
          id: 'new-current',
          senderId: '',
          receiverId: 'other',
          content: 'Current send',
          createdAt: DateTime.now(),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Failed conversation load exposes retry and reconnects', (
    tester,
  ) async {
    final repo = _Repository();
    var calls = 0;
    when(() => repo.streamMessagesWith(otherUserId: 'other')).thenAnswer((_) {
      calls++;
      return calls == 1 ? Stream.error(Exception('offline')) : Stream.value([]);
    });
    await mountChat(tester, repo);
    expect(
      find.text('Non è stato possibile caricare la conversazione.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Riprova').last);
    await tester.tap(find.text('Riprova').last);
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(
      find.text('Non è stato possibile caricare la conversazione.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Public community searches names on the server and clears search',
    (tester) async {
      const users = [
        MatchedUserPreview(
          user: AppUser(id: 'a', email: '', username: 'laura'),
          compatibility: 0,
          topArtists: [],
          city: '',
          attendingEvents: 0,
        ),
        MatchedUserPreview(
          user: AppUser(id: 'b', email: '', username: 'marco'),
          compatibility: 0,
          topArtists: [],
          city: '',
          attendingEvents: 0,
        ),
      ];
      final queries = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            publicUsersProvider.overrideWith((ref, query) async {
              queries.add(query);
              return users
                  .where(
                    (user) => user.user.username.contains(query.toLowerCase()),
                  )
                  .toList();
            }),
            pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
            conversationsProvider.overrideWith((ref) => _Conversations()),
          ],
          child: app(const DiscoverUsersScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' LAURA ');
      await tester.pump(const Duration(milliseconds: 329));
      expect(queries, ['']);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(queries.last, 'LAURA');
      expect(find.text('laura'), findsOneWidget);
      expect(find.text('marco'), findsNothing);
      await tester.enterText(find.byType(TextField), 'inesistente');
      await tester.pump(const Duration(milliseconds: 330));
      await tester.pumpAndSettle();
      expect(find.text('Nessuna persona trovata'), findsOneWidget);
      await tester.tap(find.byTooltip('Cancella ricerca'));
      await tester.pumpAndSettle();
      expect(find.text('marco'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Public community shows loading, then an error with working retry',
    (tester) async {
      final first = Completer<List<MatchedUserPreview>>();
      var calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            publicUsersProvider.overrideWith((ref, query) {
              calls++;
              return calls == 1 ? first.future : Future.value([]);
            }),
            pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
            conversationsProvider.overrideWith((ref) => _Conversations()),
          ],
          child: app(const DiscoverUsersScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Nessuna persona trovata'), findsNothing);
      first.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(
        find.text('Impossibile caricare le persone. Riprova.'),
        findsOneWidget,
      );
      expect(find.text('Nessuna persona trovata'), findsNothing);
      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('Nessuna persona trovata'), findsOneWidget);
      expect(
        find.text('Impossibile caricare le persone. Riprova.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'A late community search cannot replace the newer literal query',
    (tester) async {
      final old = Completer<List<MatchedUserPreview>>();
      final queries = <String>[];
      const current = MatchedUserPreview(
        user: AppUser(id: 'new', email: '', username: 'current'),
        compatibility: 0,
        topArtists: [],
        city: '',
        attendingEvents: 0,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            publicUsersProvider.overrideWith((ref, query) {
              queries.add(query);
              return query == 'old'
                  ? old.future
                  : Future.value(query.isEmpty ? [] : [current]);
            }),
            pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
            conversationsProvider.overrideWith((ref) => _Conversations()),
          ],
          child: app(const DiscoverUsersScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'old');
      await tester.pump(const Duration(milliseconds: 330));
      await tester.pump();
      await tester.enterText(find.byType(TextField), r' _%,name\ ');
      await tester.pump(const Duration(milliseconds: 330));
      await tester.pumpAndSettle();
      expect(queries.last, r'_%,name\');
      expect(find.text('current'), findsOneWidget);
      old.complete([]);
      await tester.pumpAndSettle();
      expect(find.text('current'), findsOneWidget);
      expect(find.text('Nessuna persona trovata'), findsNothing);
      await tester.enterText(find.byType(TextField), 'pending');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 400));
      expect(queries.contains('pending'), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Community hides retained rows while a refreshed request loads', (
    tester,
  ) async {
    const previous = MatchedUserPreview(
      user: AppUser(id: 'previous', email: '', username: 'previous'),
      compatibility: 0,
      topArtists: [],
      city: '',
      attendingEvents: 0,
    );
    final current = Completer<List<MatchedUserPreview>>();
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          publicUsersProvider.overrideWith((ref, query) {
            return ++calls == 1 ? Future.value([previous]) : current.future;
          }),
          pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
          conversationsProvider.overrideWith((ref) => _Conversations()),
        ],
        child: app(const DiscoverUsersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('previous'), findsOneWidget);
    final refreshing = tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pump();
    expect(calls, 2);
    expect(find.text('previous'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    current.complete([]);
    await refreshing;
    await tester.pumpAndSettle();
    expect(find.text('Nessuna persona trovata'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Home distinguishes feed failures and offers a real retry', (
    tester,
  ) async {
    final feed = _Feed();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allEventsProvider.overrideWith((ref) => feed),
          eventsFeedStatusProvider.overrideWith(
            (ref) => AsyncError(Exception('offline'), StackTrace.empty),
          ),
          myProfileProvider.overrideWith((ref) => _Profile()),
        ],
        child: app(const HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.scrollUntilVisible(find.text('Riprova'), 200);
    await tester.tap(find.text('Riprova'));
    await tester.pump();
    expect(feed.refreshes, 1);
    expect(find.text('Gli eventi non si sono caricati.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
