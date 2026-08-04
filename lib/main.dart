import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// Inizializza tutti i servizi prima di avviare l'UI.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza Crashlytics / Error Handler per catturare i Red Screen of Death
  GlobalErrorHandler.initialize();

  // Inizializza il Caching Offline
  await CacheService.initialize();

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
    await FirebaseBootstrap.initialize();
    await PushNotificationsBootstrap.initialize(SupabaseDatasource());
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

  runApp(ProviderScope(
    observers: [AppProviderObserver()],
    child: const VibraApp(),
  ));
}
