import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/theme/vibra_theme.dart';
import 'package:vibra/l10n/app_localizations.dart';
import 'package:vibra/presentation/providers/auth_provider.dart';
import 'package:vibra/presentation/screens/auth/login_screen.dart';
import 'package:vibra/presentation/screens/auth/welcome_screen.dart';
import 'package:vibra/presentation/widgets/common/vibra_button.dart';
import 'package:vibra/presentation/widgets/vibra_pill_button.dart';

class _Auth extends StateNotifier<GeneralAuthState>
    implements GeneralAuthNotifier {
  _Auth() : super(const GeneralAuthState.idle());
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      for (final screen in [const LoginScreen(), const WelcomeScreen()]) {
        testWidgets(
          '${screen.runtimeType} fits small phone, scale $scale, dark $dark',
          (tester) async {
            tester.view.physicalSize = const Size(320, 568);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              ProviderScope(
                overrides: [generalAuthProvider.overrideWith((_) => _Auth())],
                child: MaterialApp(
                  theme: dark ? VibraTheme.darkTheme : VibraTheme.lightTheme,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: const Locale('de'),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                  home: screen,
                ),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(seconds: 2));
            expect(tester.takeException(), isNull);
            if (screen is LoginScreen) {
              await tester.drag(
                find.byType(SingleChildScrollView).first,
                const Offset(0, -800),
              );
              await tester.pump(const Duration(seconds: 1));
              expect(find.text('E-Mail'), findsOneWidget);
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
          },
        );
      }
    }
  }
  testWidgets('Shared buttons wrap long labels without clipping', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: VibraTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 220,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VibraButton(
                      label: 'Salva tutte le modifiche del profilo',
                      onPressed: () {},
                      leadingIcon: Icons.save,
                    ),
                    const SizedBox(height: 16),
                    VibraPillButton(
                      text: 'Continua con il tuo account personale',
                      onPressed: () {},
                      icon: Icons.login,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
