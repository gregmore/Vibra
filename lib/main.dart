import 'dart:async';

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

/// Bootstrap separato per consentire ai test d'integrazione di conservare il
/// proprio handler degli errori del framework.
Future<void> bootstrapAndRun({
  bool installGlobalErrorHandler = true,
  bool initializeNativeServices = true,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Crashlytics / Error Handler per catturare i Red Screen of Death
  if (installGlobalErrorHandler) {
    GlobalErrorHandler.initialize();
  }

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

  if (initializeNativeServices && !EnvConfig.isIsolatedTest) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeNativeServices());
    });
  }

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
