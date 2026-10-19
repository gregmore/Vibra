import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/presentation/screens/social/friends_screen.dart';
import 'package:vibra/presentation/screens/social/discover_users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/screens/social/conversations_screen.dart';

import '../../helpers/test_http_overrides.dart';

class MockConversationsController
    extends StateNotifier<List<ConversationSummary>>
    implements ConversationsController {
  MockConversationsController(super.state);

  @override
  Future<void> refresh() async {
    refreshCount++;
  }

  int refreshCount = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class EmptyMatches extends StateNotifier<List<MatchedUserPreview>>
    implements MatchedUsersController {
  EmptyMatches() : super(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class EmptyFriendships extends StateNotifier<List<Friendship>>
    implements PendingFriendshipsController {
  EmptyFriendships() : super(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues(const {});
    try {
      await Supabase.initialize(
        url: 'https://fake.supabase.co',
        publishableKey: 'fakeAnonKey',
        authOptions: const FlutterAuthClientOptions(
          localStorage: EmptyLocalStorage(),
        ),
      );
    } catch (_) {
      // already initialized
    }
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  final testConversations = [
    ConversationSummary(
      otherUserId: 'friend-1',
      otherUsername: 'laura_music',
      otherDisplayName: 'Laura Bianchi',
      otherAvatarUrl: null,
      lastMessageContent: 'Ci vediamo alle 21 al concerto!',
      lastMessageCreatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isFriend: true,
      isMessageRequest: false,
    ),
    ConversationSummary(
      otherUserId: 'request-1',
      otherUsername: 'rock_lover',
      otherDisplayName: 'Marco Verdi',
      otherAvatarUrl: null,
      lastMessageContent:
          'Ciao, ho visto che vai anche tu al live di Calcutta!',
      lastMessageCreatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 1,
      isFriend: false,
      isMessageRequest: true,
    ),
  ];

  testWidgets('Friends shortcut opens messages and back returns to friends', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/conversations',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => Scaffold(body: shell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/conversations',
                  builder: (context, state) => const ConversationsScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) =>
              const ConversationsScreen(showBackButton: true),
        ),
        GoRoute(
          path: '/friends',
          builder: (context, state) => const FriendsScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationsProvider.overrideWith(
            (ref) => MockConversationsController(const []),
          ),
          matchedUsersProvider.overrideWith((ref) => EmptyMatches()),
          pendingFriendshipsProvider.overrideWith((ref) => EmptyFriendships()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
        ),
      ),
    );
    // The empty inbox has a continuous decorative animation.
    await tester.pump(const Duration(seconds: 1));
    for (var visit = 0; visit < 2; visit++) {
      await tester.tap(find.byTooltip('Amici'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text(
          lookupAppLocalizations(const Locale('it')).friendsConnectionsTitle,
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Messaggi'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(find.text('Nessuna conversazione, ancora.'), findsOneWidget);
      expect(router.canPop(), isTrue);
      expect(
        GoRouterState.of(tester.element(find.byType(BackButton))).uri.path,
        '/messages',
      );
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text(
          lookupAppLocalizations(const Locale('it')).friendsConnectionsTitle,
        ),
        findsOneWidget,
      );
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Social back returns to its origin and handles direct entry', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/social-match',
      routes: [
        GoRoute(
          path: '/social-match',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/social'),
              child: const Text('Apri Social'),
            ),
          ),
        ),
        GoRoute(
          path: '/social',
          builder: (context, state) => const DiscoverUsersScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matchedUsersProvider.overrideWith((ref) => EmptyMatches()),
          pendingFriendshipsProvider.overrideWith((ref) => EmptyFriendships()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
        ),
      ),
    );
    await tester.tap(find.text('Apri Social'));
    await tester.pumpAndSettle();
    expect(find.text('Social'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Apri Social'), findsOneWidget);
    router.go('/social');
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsNothing);
    expect(find.text('Social'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('ConversationsScreen renders tabs and conversations correctly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationsProvider.overrideWith(
            (ref) => MockConversationsController(testConversations),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: ConversationsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Messaggi'), findsWidgets);
    expect(find.text('Diretti'), findsOneWidget);
    expect(find.text('Richieste'), findsOneWidget);

    // Should see direct conversation.
    expect(find.text('Laura Bianchi'), findsOneWidget);
    expect(find.text('Ci vediamo alle 21 al concerto!'), findsOneWidget);

    // Switch to Richieste Tab.
    await tester.tap(find.text('Richieste'));
    await tester.pumpAndSettle();

    // Should see message request conversation and hide the direct list.
    expect(find.text('Marco Verdi'), findsOneWidget);
    expect(find.text('Laura Bianchi'), findsNothing);
    expect(
      find.text('Ciao, ho visto che vai anche tu al live di Calcutta!'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Unread filter combines with search and resets without losing chats',
    (tester) async {
      final controller = MockConversationsController([
        ...testConversations,
        ConversationSummary(
          otherUserId: 'read-1',
          otherUsername: 'anna',
          otherDisplayName: 'Anna Rossi',
          otherAvatarUrl: null,
          lastMessageContent: 'A presto!',
          lastMessageCreatedAt: DateTime.now(),
          unreadCount: 0,
          isFriend: true,
          isMessageRequest: false,
        ),
      ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [conversationsProvider.overrideWith((ref) => controller)],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('it'),
            home: ConversationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Anna Rossi'), findsOneWidget);
      expect(find.text('Non letti (2)'), findsOneWidget);
      await tester.tap(find.text('Non letti (2)'));
      await tester.pumpAndSettle();
      expect(find.text('Anna Rossi'), findsNothing);
      expect(find.text('Laura Bianchi'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  ANNA  ');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Nessuna conversazione trovata.'), findsOneWidget);
      expect(find.text('Nessuna conversazione, ancora.'), findsNothing);
      await tester.tap(find.text('Rimuovi filtri'));
      await tester.pumpAndSettle();
      expect(find.text('Anna Rossi'), findsOneWidget);
      expect(find.text('Laura Bianchi'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      await tester.tap(find.text('Non letti (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Richieste'));
      await tester.pumpAndSettle();
      expect(find.text('Marco Verdi'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Empty inbox can be refreshed by dragging', (tester) async {
    final controller = MockConversationsController(const []);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [conversationsProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('it'),
          home: ConversationsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.drag(find.byType(ListView).first, const Offset(0, 350));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(controller.refreshCount, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
