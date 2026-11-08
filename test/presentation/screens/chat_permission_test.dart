import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/domain/entities/direct_message.dart';
import 'package:vibra/domain/entities/direct_message_permission.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/domain/repositories/social_repository.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/direct_message_permission_provider.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/screens/social/chat_screen.dart';

import '../../helpers/test_http_overrides.dart';

class _Repository extends Mock implements SocialRepository {}

final _permission = StateProvider<DirectMessagePermission>(
  (ref) => DirectMessagePermission.allowed,
);

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
  _Requests(this.ref, List<Friendship> rows) : super(rows);
  @override
  final Ref ref;
  List<Friendship> refreshRows = [];
  final accepted = <String>[];
  @override
  Future<void> refresh() async => state = refreshRows;
  @override
  Future<void> acceptFriendRequest(String id) async {
    accepted.add(id);
    state = [];
    ref.read(_permission.notifier).state = DirectMessagePermission.friends;
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
      publishableKey: 'fake-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
  });
  tearDownAll(() => HttpOverrides.global = null);
  late _Requests requests;
  late _Repository repository;

  Future<void> mount(
    WidgetTester tester,
    DirectMessagePermission permission, {
    List<Friendship> friendships = const [],
  }) async {
    repository = _Repository();
    when(
      () => repository.streamMessagesWith(otherUserId: 'other'),
    ).thenAnswer((_) => Stream.value([]));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          _permission.overrideWith((ref) => permission),
          directMessagePermissionProvider.overrideWith(
            (ref, id) async => ref.watch(_permission),
          ),
          pendingFriendshipsProvider.overrideWith(
            (ref) => requests = _Requests(ref, friendships),
          ),
          friendsProvider.overrideWithValue([]),
          conversationsProvider.overrideWith((ref) => _Conversations()),
          streamConversationUseCaseProvider.overrideWithValue(
            StreamConversationUseCase(repository),
          ),
          sendDirectMessageUseCaseProvider.overrideWithValue(
            SendDirectMessageUseCase(repository),
          ),
          requestFriendshipUseCaseProvider.overrideWithValue(
            RequestFriendshipUseCase(repository),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChatScreen(
            otherUserId: 'other',
            otherDisplayName: 'Laura',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Distant contact preserves the draft and offers one friendship request',
    (tester) async {
      await mount(tester, DirectMessagePermission.friendshipRequired);
      await tester.enterText(find.byType(TextField), 'La mia bozza');
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
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ChatScreen)),
      )!;
      expect(find.text(l10n.chatSendFriendshipRequired), findsOneWidget);
      const pending = Friendship(
        id: 'request',
        requesterId: '',
        receiverId: 'other',
        status: 'pending',
      );
      requests.refreshRows = [pending];
      when(
        () => repository.requestFriendship(receiverId: 'other'),
      ).thenAnswer((_) async => pending);
      await tester.tap(find.text(l10n.chatRequestFriendship));
      await tester.pumpAndSettle();
      verify(() => repository.requestFriendship(receiverId: 'other')).called(1);
      verifyNever(
        () => repository.sendMessage(
          receiverId: 'other',
          content: 'La mia bozza',
        ),
      );
      expect(find.text(l10n.chatFriendshipRequestPending), findsOneWidget);
      expect(find.text(l10n.chatRequestFriendship), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'La mia bozza',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Accepting an incoming friendship enables sending without GPS', (
    tester,
  ) async {
    await mount(
      tester,
      DirectMessagePermission.friendshipRequired,
      friendships: const [
        Friendship(
          id: 'incoming',
          requesterId: 'other',
          receiverId: '',
          status: 'pending',
        ),
      ],
    );
    final l10n = AppLocalizations.of(tester.element(find.byType(ChatScreen)))!;
    await tester.enterText(find.byType(TextField), 'Ciao');
    await tester.tap(find.text(l10n.chatAcceptFriendship));
    await tester.pumpAndSettle();
    expect(requests.accepted, ['incoming']);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton && widget.tooltip == 'Invia messaggio',
            ),
          )
          .onPressed,
      isNotNull,
    );
    when(
      () => repository.sendMessage(receiverId: 'other', content: 'Ciao'),
    ).thenAnswer(
      (_) async => DirectMessage(
        id: 'sent',
        senderId: '',
        receiverId: 'other',
        content: 'Ciao',
        createdAt: DateTime.now(),
      ),
    );
    await tester.tap(find.byTooltip('Invia messaggio'));
    await tester.pumpAndSettle();
    verify(
      () => repository.sendMessage(receiverId: 'other', content: 'Ciao'),
    ).called(1);
    expect(find.text('Ciao'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'A changed first-contact permission explains failure and recovers the draft',
    (tester) async {
      await mount(tester, DirectMessagePermission.allowed);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ChatScreen)),
      )!;
      when(
        () => repository.sendMessage(
          receiverId: 'other',
          content: 'Quarto messaggio',
        ),
      ).thenThrow(
        const DirectMessageSendException(DirectMessagePermission.awaitingReply),
      );
      await tester.enterText(find.byType(TextField), 'Quarto messaggio');
      await tester.pump();
      await tester.tap(find.byTooltip('Invia messaggio'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          '${l10n.chatSendFirstContactLimit} ${l10n.chatDraftRecovered}',
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Quarto messaggio',
      );
      expect(find.text('Quarto messaggio'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Unavailable conversations have no misleading friendship action',
    (tester) async {
      await mount(tester, DirectMessagePermission.unavailable);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(ChatScreen)),
      )!;
      expect(find.text(l10n.chatSendUnavailable), findsOneWidget);
      expect(find.text(l10n.chatRequestFriendship), findsNothing);
      expect(find.text(l10n.chatAcceptFriendship), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
