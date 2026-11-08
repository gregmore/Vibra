import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/widgets/common/vibra_paged_list.dart';

/// Lazy, paged lists (docs/performance.md).
void main() {
  final all = List.generate(45, (i) => i);

  Widget app(List<int> first, Future<List<int>> Function(int last) more) =>
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: VibraPagedList<int>(
            first: first,
            pageSize: 20,
            loadMore: more,
            itemKey: (i) => i,
            itemBuilder: (context, i) =>
                SizedBox(height: 80, child: Text('item $i')),
          ),
        ),
      );

  testWidgets('builds lazily and loads the next pages near the end', (
    tester,
  ) async {
    final asked = <int>[];
    Future<List<int>> more(int last) async {
      asked.add(last);
      return all.where((i) => i > last).take(20).toList();
    }

    await tester.pumpWidget(app(all.take(20).toList(), more));
    await tester.pumpAndSettle();
    // Only what fits on screen is built.
    expect(find.text('item 19'), findsNothing);
    expect(asked, isEmpty);

    await tester.scrollUntilVisible(find.text('item 44'), 600);
    await tester.pumpAndSettle();
    expect(asked, [19, 39]);
    // The last page was short: no further request, no spinner.
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(asked, [19, 39]);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a failed page offers a retry instead of looping', (
    tester,
  ) async {
    var calls = 0;
    var fail = true;
    Future<List<int>> more(int last) async {
      calls++;
      if (fail) throw Exception('offline');
      return [last + 1];
    }

    await tester.pumpWidget(app(all.take(20).toList(), more));
    await tester.scrollUntilVisible(find.text('Retry'), 600);
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 1);

    fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('item 20'), 300);
    expect(calls, 2);
  });

  testWidgets('a new first page starts over', (tester) async {
    await tester.pumpWidget(app([1, 2], (_) async => const []));
    expect(find.text('item 1'), findsOneWidget);
    await tester.pumpWidget(app([7], (_) async => const []));
    expect(find.text('item 1'), findsNothing);
    expect(find.text('item 7'), findsOneWidget);
  });
}
