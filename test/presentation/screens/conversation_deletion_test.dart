import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/usecases/social_usecases.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/app_state_providers.dart';
import 'package:vibra/presentation/providers/usecase_providers.dart';
import 'package:vibra/presentation/screens/social/conversations_screen.dart';

class _Delete implements SoftDeleteChatUseCase {
  int calls = 0;
  bool fail = false;
  @override
  Future<void> call(String userId) async {
    calls++;
    if (fail) throw Exception('offline');
  }
}

class _Conversations extends StateNotifier<List<ConversationSummary>>
    implements ConversationsController {
  _Conversations(super.state);
  int refreshes = 0;
  @override
  Future<void> refresh() async {
    refreshes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final conversation = ConversationSummary(
    otherUserId: 'laura',
    otherUsername: 'Laura',
    lastMessageContent: 'Ciao!',
    lastMessageCreatedAt: DateTime.now(),
    unreadCount: 0,
    isFriend: true,
    isMessageRequest: false,
  );

  Future<void> mount(
    WidgetTester tester,
    _Delete delete,
    _Conversations controller,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conversationsProvider.overrideWith((ref) => controller),
          softDeleteChatUseCaseProvider.overrideWithValue(delete),
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
  }

  Future<void> openConfirmation(WidgetTester tester) async {
    await tester.longPress(find.text('Laura'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina conversazione'));
    await tester.pumpAndSettle();
    expect(find.text('Eliminare la conversazione?'), findsOneWidget);
  }

  testWidgets('Cancel leaves the conversation intact and avoids deletion', (
    tester,
  ) async {
    final delete = _Delete();
    final controller = _Conversations([conversation]);
    await mount(tester, delete, controller);
    await openConfirmation(tester);
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(delete.calls, 0);
    expect(controller.refreshes, 0);
    expect(find.text('Laura'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Successful deletion refreshes the inbox and shows feedback', (
    tester,
  ) async {
    final delete = _Delete();
    final controller = _Conversations([conversation]);
    await mount(tester, delete, controller);
    await openConfirmation(tester);
    await tester.tap(find.text('Elimina conversazione'));
    await tester.pumpAndSettle();
    expect(delete.calls, 1);
    expect(controller.refreshes, 1);
    expect(find.text('Conversazione eliminata.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Deletion errors keep the inbox usable and show an error', (
    tester,
  ) async {
    final delete = _Delete()..fail = true;
    final controller = _Conversations([conversation]);
    await mount(tester, delete, controller);
    await openConfirmation(tester);
    await tester.tap(find.text('Elimina conversazione'));
    await tester.pumpAndSettle();
    expect(controller.refreshes, 0);
    expect(find.text('Laura'), findsOneWidget);
    expect(
      find.text('La conversazione non è stata eliminata. Riprova.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
