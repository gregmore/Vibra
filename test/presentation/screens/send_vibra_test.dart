import 'package:vibra/core/constants/app_constants.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/data/datasources/supabase_datasource.dart';
import 'package:vibra/data/datasources/supabase_social_datasource.dart';
import 'package:vibra/data/models/friendship_model.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/screens/social/social_match_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_button.dart';

class _Datasource extends Mock implements SupabaseDatasource {}

class _Social extends Mock implements SupabaseSocialDatasource {}

class _Client extends Mock implements SupabaseClient {}

class _Channel extends Mock implements RealtimeChannel {}

class _Profile extends StateNotifier<AppUser> implements ProfileController {
  _Profile() : super(const AppUser(id: 'me', email: '', username: 'me'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Request implements RequestFriendshipUseCase {
  Completer<Friendship>? _result;
  Completer<Friendship> get result => _result ??= Completer<Friendship>();
  int calls = 0;
  String? target;
  @override
  Future<Friendship> call(String userId) {
    calls++;
    target = userId;
    return result.future;
  }
}

void main() {
  // Exercise the retained integration with --dart-define=SPOTIFY_ENABLED=true.
  if (!AppConstants.spotifyEnabled) return;
  setUpAll(() => registerFallbackValue((PostgresChangePayload payload) {}));
  late _Social social;
  late _Request request;
  late ProviderContainer container;
  List<FriendshipModel> pending = [];
  const friendship = Friendship(
    id: 'request',
    requesterId: 'me',
    receiverId: 'laura',
    status: 'pending',
  );

  setUp(() {
    social = _Social();
    request = _Request();
    pending = [];
    final datasource = _Datasource();
    final client = _Client();
    final channel = _Channel();
    when(() => datasource.currentUser).thenReturn(
      User(
        id: 'me',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-10-07',
      ),
    );
    when(() => datasource.client).thenReturn(client);
    when(() => client.channel(any())).thenReturn(channel);
    when(
      () => channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'user_matches',
        callback: any(named: 'callback'),
      ),
    ).thenReturn(channel);
    when(() => channel.subscribe()).thenReturn(channel);
    when(() => channel.unsubscribe()).thenAnswer((_) async => 'ok');
    when(() => social.listMyMatches(limit: 20)).thenAnswer(
      (_) async => [
        {'user_id_a': 'me', 'user_id_b': 'laura', 'compatibility': 90},
        {'user_id_a': 'me', 'user_id_b': 'marco', 'compatibility': 85},
      ],
    );
    when(() => social.getPublicUsersByIds(any())).thenAnswer(
      (_) async => [
        {'id': 'laura', 'username': 'laura', 'display_name': 'Laura'},
        {'id': 'marco', 'username': 'marco', 'display_name': 'Marco'},
      ],
    );
    when(
      () => social.listMyFriendships(status: 'accepted'),
    ).thenAnswer((_) async => []);
    when(
      () => social.listMyFriendships(status: 'pending'),
    ).thenAnswer((_) async => pending);
    when(
      () => social.getMusicProfilesByUserIds(any()),
    ).thenAnswer((_) async => []);
    container = ProviderContainer(
      overrides: [
        supabaseDatasourceProvider.overrideWithValue(datasource),
        supabaseSocialDatasourceProvider.overrideWithValue(social),
        requestFriendshipUseCaseProvider.overrideWithValue(request),
        myProfileProvider.overrideWith((ref) => _Profile()),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('it'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const SocialMatchScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Send waits for backend confirmation, locks controls, then advances',
    (tester) async {
      await mount(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(Dismissible),
          matching: find.text('Invia Vibra'),
        ),
      );
      await tester.pump();
      expect(request.calls, 1);
      expect(request.target, 'laura');
      expect(container.read(matchedUsersProvider).first.user.id, 'laura');
      expect(find.text('Vibra inviata a Laura! 🎉'), findsNothing);
      final send = tester.widget<VibraButton>(
        find.descendant(
          of: find.byType(Dismissible),
          matching: find.byWidgetPredicate(
            (widget) => widget is VibraButton && widget.label == 'Invia Vibra',
          ),
        ),
      );
      expect(send.loading, isTrue);
      expect(send.onPressed, isNull);
      expect(
        tester.widget<Dismissible>(find.byType(Dismissible)).direction,
        DismissDirection.none,
      );
      expect(request.calls, 1);
      request.result.complete(friendship);
      await tester.pumpAndSettle();
      expect(container.read(matchedUsersProvider).first.user.id, 'marco');
      expect(find.text('Vibra inviata a Laura! 🎉'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Send failures keep the profile available and avoid false success',
    (tester) async {
      await mount(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(Dismissible),
          matching: find.text('Invia Vibra'),
        ),
      );
      await tester.pump();
      request.result.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(container.read(matchedUsersProvider).first.user.id, 'laura');
      expect(find.text('Vibra inviata a Laura! 🎉'), findsNothing);
      expect(
        find.text(
          'Vibra non inviata. Riprova: il profilo è ancora disponibile.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Swipe failures restore the card without dismissing it', (
    tester,
  ) async {
    await mount(tester);
    await tester.drag(find.byType(Dismissible), const Offset(650, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(request.calls, 1);
    request.result.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(container.read(matchedUsersProvider).first.user.id, 'laura');
    expect(find.byKey(const ValueKey('laura')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Concurrent controller calls share one backend request', (
    tester,
  ) async {
    final controller = container.read(matchedUsersProvider.notifier);
    await tester.pump();
    final first = controller.sendVibra('laura');
    final second = controller.sendVibra('laura');
    expect(identical(first, second), isTrue);
    expect(request.calls, 1);
    request.result.complete(friendship);
    await tester.pump();
    await first;
    await second;
    expect(
      container
          .read(matchedUsersProvider)
          .any((match) => match.user.id == 'laura'),
      isFalse,
    );
  });

  testWidgets(
    'Refresh excludes outgoing pending requests but retains incoming matches',
    (tester) async {
      pending = [
        const FriendshipModel(
          id: 'sent',
          requesterId: 'me',
          receiverId: 'laura',
          status: 'pending',
        ),
        const FriendshipModel(
          id: 'received',
          requesterId: 'marco',
          receiverId: 'me',
          status: 'pending',
        ),
      ];
      final controller = container.read(matchedUsersProvider.notifier);
      await tester.pump();
      expect(
        container.read(matchedUsersProvider).map((match) => match.user.id),
        ['marco'],
      );
      await controller.refresh();
      expect(
        container.read(matchedUsersProvider).map((match) => match.user.id),
        ['marco'],
      );
    },
  );

  testWidgets(
    'A stale feed response cannot restore a successfully sent match',
    (tester) async {
      final controller = container.read(matchedUsersProvider.notifier);
      await tester.pump();
      final profiles = Completer<List<Map<String, dynamic>>>();
      when(
        () => social.getMusicProfilesByUserIds(any()),
      ).thenAnswer((_) => profiles.future);
      final refresh = controller.refresh();
      await tester.pump();
      final send = controller.sendVibra('laura');
      request.result.complete(friendship);
      await tester.pump();
      await send;
      profiles.complete([]);
      await tester.pump();
      await refresh;
      expect(
        container.read(matchedUsersProvider).map((match) => match.user.id),
        ['marco'],
      );
    },
  );

  testWidgets(
    'Completing a send after leaving the provider does not update disposed state',
    (tester) async {
      final controller = container.read(matchedUsersProvider.notifier);
      await tester.pump();
      final send = controller.sendVibra('laura');
      container.invalidate(matchedUsersProvider);
      await tester.pump(const Duration(milliseconds: 1));
      expect(controller.mounted, isFalse);
      request.result.complete(friendship);
      await tester.pump();
      await send;
      expect(request.calls, 1);
    },
  );

  testWidgets(
    'Existing friends stay in the friends list without receiving another Vibra',
    (tester) async {
      when(() => social.listMyFriendships(status: 'accepted')).thenAnswer(
        (_) async => [
          const FriendshipModel(
            id: 'friend',
            requesterId: 'me',
            receiverId: 'laura',
            status: 'accepted',
          ),
        ],
      );
      await mount(tester);
      expect(container.read(friendsProvider).single.user.id, 'laura');
      expect(find.byKey(const ValueKey('laura')), findsNothing);
      expect(find.byKey(const ValueKey('marco')), findsOneWidget);
      expect(request.calls, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
