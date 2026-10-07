import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/presentation/widgets/vibra_signal_wave.dart';

void main() {
  testWidgets('Wave animation repaints without rebuilding the widget tree', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(width: 200, child: VibraSignalWave(animate: true)),
      ),
    );
    final finder = find.descendant(
      of: find.byType(VibraSignalWave),
      matching: find.byType(CustomPaint),
    );
    final before = tester.widget<CustomPaint>(finder);
    await tester.pump(const Duration(milliseconds: 300));
    expect(identical(before, tester.widget<CustomPaint>(finder)), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Wave stops for reduced motion and when its page is hidden', (
    tester,
  ) async {
    Future<void> mount({
      required bool hidden,
      required bool reducedMotion,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reducedMotion),
            child: TickerMode(
              enabled: !hidden,
              child: const SizedBox(
                width: 200,
                child: VibraSignalWave(animate: true),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
    }

    await mount(hidden: false, reducedMotion: true);
    await mount(hidden: true, reducedMotion: false);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
