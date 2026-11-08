import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/core/constants/app_constants.dart';
import 'package:vibra/domain/entities/app_user.dart';
import 'package:vibra/domain/entities/friendship.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/public_friends_provider.dart';
import 'package:vibra/presentation/screens/social/friends_screen.dart';

class _Requests extends StateNotifier<List<Friendship>>
    implements PendingFriendshipsController {
  _Requests() : super(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Future<List<MatchedUserPreview>> Function() load) => ProviderScope(
  overrides: [
    pendingFriendshipsProvider.overrideWith((ref) => _Requests()),
    publicFriendsProvider.overrideWith((ref) => load()),
    publicConnectionProfilesProvider.overrideWith((ref) async => const []),
    matchedUsersProvider.overrideWith(
      (ref) => throw StateError('Music matching is not required for friends'),
    ),
  ],
  child: const MaterialApp(
    locale: Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: FriendsScreen(),
  ),
);

void main() {
  setUpAll(() async {
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
      // Test process may already have initialized the isolated client.
    }
  });

  testWidgets(
    'friends loading never appears as an empty friends list',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final result = Completer<List<MatchedUserPreview>>();
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.pumpWidget(_app(() => result.future));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(l10n.commonLoading), findsOneWidget);
      expect(find.text(l10n.friendsNoneFound), findsNothing);

      result.complete(const [
        MatchedUserPreview(
          user: AppUser(id: 'friend', email: '', username: 'martina'),
          compatibility: 0,
          topArtists: [],
          city: '',
          attendingEvents: 0,
          isFriend: true,
        ),
      ]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('martina'), findsOneWidget);
      expect(find.text(l10n.friendsNoneFound), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
    skip: AppConstants.spotifyEnabled,
  );

  testWidgets(
    'friends load failure offers a localized retry instead of empty',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var calls = 0;
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.pumpWidget(
        _app(() async {
          calls++;
          if (calls == 1) throw StateError('isolated connection failure');
          return const [];
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text(l10n.friendsLoadError), findsOneWidget);
      expect(find.text(l10n.friendsNoneFound), findsNothing);
      await tester.tap(find.text(l10n.commonRetry));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(calls, 2);
      expect(find.text(l10n.friendsNoneFound), findsOneWidget);
      expect(find.text(l10n.friendsLoadError), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    },
    skip: AppConstants.spotifyEnabled,
  );
}
