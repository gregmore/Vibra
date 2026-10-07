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
import 'package:vibra/domain/entities/event.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/domain/repositories/social_repository.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
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

class _Matches extends StateNotifier<List<MatchedUserPreview>>
    implements MatchedUsersController {
  _Matches(super.state);
  int refreshes = 0;
  @override
  Future<void> refresh() async {
    refreshes++;
  }

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

  testWidgets('Social searches artists and restores the list when cleared', (
    tester,
  ) async {
    final matches = _Matches([
      const MatchedUserPreview(
        user: AppUser(id: 'a', email: '', username: 'laura'),
        compatibility: 90,
        topArtists: ['Calcutta'],
        city: 'Roma',
        attendingEvents: 0,
      ),
      const MatchedUserPreview(
        user: AppUser(id: 'b', email: '', username: 'marco'),
        compatibility: 80,
        topArtists: ['Muse'],
        city: 'Roma',
        attendingEvents: 0,
      ),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchedUsersProvider.overrideWith((ref) => matches),
          pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
          conversationsProvider.overrideWith((ref) => _Conversations()),
        ],
        child: app(const DiscoverUsersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' CALCUTTA ');
    await tester.pumpAndSettle();
    expect(find.text('laura'), findsOneWidget);
    expect(find.text('marco'), findsNothing);
    await tester.enterText(find.byType(TextField), 'inesistente');
    await tester.pumpAndSettle();
    expect(find.text('Nessuna persona trovata.'), findsOneWidget);
    await tester.tap(find.byTooltip('Cancella ricerca'));
    await tester.pumpAndSettle();
    expect(find.text('marco'), findsOneWidget);
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
