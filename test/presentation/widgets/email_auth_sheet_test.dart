import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/theme/vibra_theme.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/auth_provider.dart';
import 'package:vibra/presentation/widgets/email_auth_sheet.dart';

class _Auth extends StateNotifier<GeneralAuthState>
    implements GeneralAuthNotifier {
  _Auth() : super(const GeneralAuthState.idle());
  final pending = Completer<void>();
  String? password;
  @override
  Future<void> signInWithEmail(String email, String password) async {
    this.password = password;
    await pending.future;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets(
    'Email login preserves password spaces and survives sheet dismissal',
    (tester) async {
      final auth = _Auth();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [generalAuthProvider.overrideWith((_) => auth)],
          child: MaterialApp(
            theme: VibraTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('it'),
            home: const Scaffold(body: EmailAuthSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'person@example.invalid',
      );
      await tester.enterText(find.byType(TextFormField).last, ' pass word ');
      final submit = find.text('Accedi');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      expect(auth.password, ' pass word ');
      await tester.pumpWidget(const SizedBox.shrink());
      auth.pending.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
