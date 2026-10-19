import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/theme/vibra_theme_tokens.dart';
import 'package:vibra/presentation/widgets/vibra_match_scanner.dart';

void main() {
  Widget buildScanner({
    required Brightness brightness,
    bool disableAnimations = false,
  }) {
    final tokens = brightness == Brightness.dark
        ? VibraThemeTokens.dark
        : VibraThemeTokens.light;

    return MaterialApp(
      theme: ThemeData(brightness: brightness, extensions: [tokens]),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const Scaffold(
          body: Center(
            child: VibraMatchScanner(
              title: 'Cerchiamo la tua frequenza',
              subtitle: 'Incrociamo artisti, generi ed eventi.',
            ),
          ),
        ),
      ),
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets('renders without errors in ${brightness.name} mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildScanner(brightness: brightness));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.byType(VibraMatchScanner), findsOneWidget);
      expect(find.text('Cerchiamo la tua frequenza'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('honours reduced motion', (tester) async {
    await tester.pumpWidget(
      buildScanner(brightness: Brightness.dark, disableAnimations: true),
    );
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(VibraMatchScanner), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
