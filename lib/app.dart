import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibra/l10n/app_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/vibra_theme.dart';
import 'presentation/providers/core_providers.dart';
import 'presentation/providers/app_state_providers.dart';
import 'presentation/providers/app_synchronization_provider.dart';
import 'presentation/widgets/support_feedback_prompt.dart';
import 'presentation/widgets/service_status_banner.dart';

/// App principale Vibra.
/// Collega Riverpod, GoRouter e design system.
class VibraApp extends ConsumerStatefulWidget {
  const VibraApp({super.key});

  @override
  ConsumerState<VibraApp> createState() => _VibraAppState();
}

class _VibraAppState extends ConsumerState<VibraApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _touchActivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _touchActivity();
      ref.read(appSynchronizationProvider).onAppResumed();
    }
  }

  @override
  void didChangePlatformBrightness() {
    // ThemeMode.system already tracks this event; rebuilding ensures token
    // consumers update immediately even when the app remains foregrounded.
    if (ref.read(themePreferenceProvider) == VibraThemePreference.system) {
      setState(() {});
    }
  }

  Future<void> _touchActivity() async {
    try {
      final datasource = ref.read(supabaseDatasourceProvider);
      if (datasource.currentUser != null) {
        await datasource.client.rpc('touch_my_activity');
      }
    } catch (_) {
      // Activity measurement must never affect app startup or navigation.
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appSynchronizationProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeStateProvider);
    final themePreference = ref.watch(themePreferenceProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: VibraTheme.lightTheme,
      darkTheme: VibraTheme.darkTheme,
      themeMode: themeModeForPreference(themePreference),
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => ServiceStatusBanner(
        child: SupportFeedbackPrompt(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
