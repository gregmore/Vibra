import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vibra/core/errors/exceptions.dart';
import 'package:vibra/data/datasources/supabase_vibra_ai_datasource.dart';
import 'package:vibra/domain/entities/vibra_ai.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/core_providers.dart';
import 'package:vibra/presentation/screens/assistant/vibra_ai_screen.dart';

class _Source extends Mock implements SupabaseVibraAiDatasource {}

void main() {
  late _Source source;

  setUp(() {
    source = _Source();
    when(() => source.setConsent(any())).thenAnswer((_) async {});
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseVibraAiDatasourceProvider.overrideWithValue(source),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: VibraAiScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('no provider configured: unavailable, nothing else asked', (
    tester,
  ) async {
    when(
      () => source.status(),
    ).thenAnswer((_) async => const AiStatus(available: false, consent: false));
    await mount(tester);
    expect(find.text("VIBRA AI isn't available"), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    verifyNever(() => source.ask(any()));
  });

  testWidgets('off until the user explicitly turns it on', (tester) async {
    var consent = false;
    when(
      () => source.status(),
    ).thenAnswer((_) async => AiStatus(available: true, consent: consent));
    await mount(tester);
    expect(find.text('Meet your music assistant'), findsOneWidget);
    expect(find.textContaining('Anthropic'), findsOneWidget);
    expect(find.textContaining('Spotify login'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    consent = true;
    await tester.tap(find.text('Turn on VIBRA AI'));
    await tester.pumpAndSettle();
    verify(() => source.setConsent(true)).called(1);
    expect(find.text('What do you want to discover?'), findsOneWidget);
  });

  testWidgets('answers separate verified results from generated text', (
    tester,
  ) async {
    when(
      () => source.status(),
    ).thenAnswer((_) async => const AiStatus(available: true, consent: true));
    when(() => source.ask(any())).thenAnswer(
      (_) async => const AiAnswer(
        text: 'Here are artists close to Travis Scott.',
        verified: [
          AiVerifiedItem(
            ref: 'spotify:artist:0Y5tJX1MQlPlqiwlOH1tJY',
            kind: AiItemKind.artist,
            title: 'Don Toliver',
            subtitle: 'rap, melodic rap',
            source: 'spotify',
            note: 'Same melodic, atmospheric sound.',
          ),
          AiVerifiedItem(
            ref: 'community:c1',
            kind: AiItemKind.community,
            title: 'Trap Nation',
            subtitle: '12',
            source: 'vibra_communities',
          ),
        ],
        ideas: [AiIdea(title: 'Explore cloud rap', kind: 'genre')],
      ),
    );
    await mount(tester);
    await tester.tap(find.text('Recommend artists similar to Travis Scott'));
    await tester.pumpAndSettle();
    verify(() => source.ask(any())).called(1);
    expect(
      find.text('Recommend artists similar to Travis Scott'),
      findsOneWidget,
    );
    expect(find.text('AI-generated · may contain mistakes'), findsOneWidget);
    expect(find.text('Verified results'), findsOneWidget);
    expect(find.text('Don Toliver'), findsOneWidget);
    expect(find.text('Verified on Spotify'), findsOneWidget);
    expect(find.text('12 members'), findsOneWidget);
    expect(find.text('Generated suggestions, not verified.'), findsOneWidget);
    expect(find.text('Explore cloud rap'), findsOneWidget);
  });

  testWidgets('limits and refusals are explained, not crashes', (tester) async {
    when(
      () => source.status(),
    ).thenAnswer((_) async => const AiStatus(available: true, consent: true));
    when(() => source.ask(any())).thenThrow(
      const ServerException(message: 'rate_limited', statusCode: 429),
    );
    await mount(tester);
    await tester.enterText(find.byType(TextField), 'Find concerts');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(
      find.text("You've asked a lot. Try again in a little while."),
      findsOneWidget,
    );
    when(
      () => source.ask(any()),
    ).thenAnswer((_) async => const AiAnswer(text: '', status: 'refused'));
    await tester.enterText(find.byType(TextField), 'Something else');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(
      find.text("VIBRA AI can't help with that. Try a music question."),
      findsOneWidget,
    );
  });
}
