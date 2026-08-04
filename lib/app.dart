import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibra/l10n/app_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/vibra_theme.dart';
import 'presentation/providers/core_providers.dart';
import 'presentation/providers/app_state_providers.dart';

/// App principale Vibra.
/// Collega Riverpod, GoRouter e design system.
class VibraApp extends ConsumerWidget {
  const VibraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeStateProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: VibraTheme.darkTheme,
      darkTheme: VibraTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
