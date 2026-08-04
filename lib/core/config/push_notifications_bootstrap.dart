import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import 'firebase_bootstrap.dart';
import '../../data/datasources/supabase_datasource.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Configura log minimali o inizializza servizi essenziali
  VibraLogger.info('Handling a background message: ${message.messageId}', tag: 'Push');
}

/// Bootstrap best-effort per push notifications.
///
/// Obiettivi:
/// - chiedere il permesso notifiche
/// - ottenere il token FCM
/// - salvarlo in `public.users.fcm_token`
/// - aggiornare il token quando Firebase ne emette uno nuovo
///
/// Se Firebase non è configurato o l'utente non è autenticato, il bootstrap
/// termina senza interrompere l'avvio dell'app.
class PushNotificationsBootstrap {
  PushNotificationsBootstrap._();

  static StreamSubscription<String>? _tokenRefreshSub;
  static StreamSubscription<AuthState>? _authStateSub;
  static bool _started = false;

  static Future<void> initialize(SupabaseDatasource supabase) async {
    if (_started) return;
    _started = true;

    if (!FirebaseBootstrap.isInitialized) {
      VibraLogger.warning(
        'Push bootstrap saltato: Firebase non inizializzato',
        tag: 'Push',
      );
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      VibraLogger.info(
        'Permesso notifiche: ${settings.authorizationStatus.name}',
        tag: 'Push',
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      if (!supabase.isAuthenticated) {
        VibraLogger.warning(
          'Push bootstrap in attesa: nessun utente autenticato',
          tag: 'Push',
        );
      } else {
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await _persistToken(supabase, token);
        }
      }

      _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
        try {
          if (supabase.isAuthenticated && token.isNotEmpty) {
            await _persistToken(supabase, token);
          }
        } catch (error, stackTrace) {
          VibraLogger.error(
            'Errore aggiornamento token FCM',
            error: error,
            stackTrace: stackTrace,
          );
        }
      });

      _authStateSub = supabase.client.auth.onAuthStateChange.listen((data) async {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          try {
            final token = await messaging.getToken();
            if (token != null && token.isNotEmpty) {
              await _persistToken(supabase, token);
            }
          } catch (e) {
            final errorString = e.toString();
            if (errorString.contains('apns-token-not-set')) {
              VibraLogger.info('APNS token non disponibile post-login (comune su Simulatori iOS).', tag: 'Push');
            } else {
              VibraLogger.error(
                'Errore durante il recupero del token FCM post-login',
                error: e,
              );
            }
          }
        }
      });
    } catch (error, stackTrace) {
      final errorString = error.toString();
      if (errorString.contains('apns-token-not-set')) {
        VibraLogger.info(
          'Push bootstrap in attesa: APNS token non ancora disponibile (comune su Simulatori iOS).',
          tag: 'Push',
        );
      } else {
        VibraLogger.warning(
          'Push bootstrap fallito: $error',
          tag: 'Push',
        );
        VibraLogger.debug(stackTrace.toString(), tag: 'Push');
      }
    }
  }

  static Future<void> _persistToken(
    SupabaseDatasource supabase,
    String token,
  ) async {
    final user = supabase.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final isPushEnabled = prefs.getBool('push_enabled') ?? true;

    await supabase.client.from('users').upsert({
      'id': user.id,
      'email': user.email ?? '',
      'fcm_token': isPushEnabled ? token : null,
    }, onConflict: 'id');

    VibraLogger.info('Token FCM sincronizzato su Supabase (abilitato: $isPushEnabled)', tag: 'Push');
  }

  static Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    await _authStateSub?.cancel();
    _authStateSub = null;
    _started = false;
  }
}

