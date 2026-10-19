import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/config/firebase_bootstrap.dart';
import 'core/config/push_notifications_bootstrap.dart';
import 'core/config/supabase_client.dart';
import 'data/datasources/supabase_datasource.dart';
import 'core/errors/exceptions.dart';
import 'core/utils/logger.dart';

import 'core/errors/global_error_handler.dart';
import 'core/observers/app_provider_observer.dart';

import 'core/services/cache_service.dart';

/// Entry point dell'app Vibra.
/// Inizializza i servizi essenziali prima di avviare l'UI.
void main() async {
  await bootstrapAndRun();
}

/// Avvia l'app con autenticazione e servizi nativi abilitati.
Future<void> bootstrapAndRun() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final family in ['inter', 'syne']) {
      final license = await rootBundle.loadString(
        'assets/fonts/$family-OFL.txt',
      );
      yield LicenseEntryWithLineBreaks(['${family}_font'], license);
    }
  });

  GlobalErrorHandler.initialize();

  // Inizializza il Caching Offline
  await CacheService.initialize();
  // Purge images cached by older app versions before restoring a session.
  await DefaultCacheManager().emptyCache();

  // Forza orientamento verticale
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Stile status bar trasparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    await EnvConfig.load();
    await SupabaseBootstrap.initialize();
  } on ConfigurationException catch (error, stackTrace) {
    VibraLogger.warning(
      'Configurazione incompleta: ${error.message}. L\'app partirà in modalità bootstrap.',
      tag: 'Config',
    );
    VibraLogger.debug(stackTrace.toString(), tag: 'Config');
  } catch (error, stackTrace) {
    VibraLogger.error(
      'Errore durante il bootstrap iniziale',
      error: error,
      stackTrace: stackTrace,
    );
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeNativeServices());
  });

  runApp(
    ProviderScope(observers: [AppProviderObserver()], child: const VibraApp()),
  );
}

Future<void> _initializeNativeServices() async {
  try {
    await FirebaseBootstrap.initialize();
    await PushNotificationsBootstrap.initialize(SupabaseDatasource());
  } catch (error, stackTrace) {
    VibraLogger.error(
      'Errore durante l’avvio dei servizi notifiche',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
