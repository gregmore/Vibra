import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import 'firebase_bootstrap.dart';
import '../../data/datasources/supabase_datasource.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Configura log minimali o inizializza servizi essenziali
  VibraLogger.info(
    'Handling a background message: ${message.messageId}',
    tag: 'Push',
  );
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

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle message in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        VibraLogger.info(
          'Messaggio ricevuto in foreground: ${message.notification?.title}',
          tag: 'Push',
        );
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null &&
            context.mounted &&
            message.notification != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${message.notification?.title ?? ''}: ${message.notification?.body ?? ''}',
              ),
              action: SnackBarAction(
                label: 'APRI',
                onPressed: () {
                  final currentCtx = AppRouter.rootNavigatorKey.currentContext;
                  if (currentCtx != null && currentCtx.mounted) {
                    _handleMessageClick(message, currentCtx);
                  }
                },
              ),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });

      // Handle message tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        VibraLogger.info('Notifica tappata (app in background)!', tag: 'Push');
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          _handleMessageClick(message, context);
        }
      });

      // Handle message tap when app was terminated
      messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          VibraLogger.info('Notifica tappata (app terminata)!', tag: 'Push');
          // Give the router some time to mount
          Future.delayed(const Duration(milliseconds: 1500), () {
            final context = AppRouter.rootNavigatorKey.currentContext;
            if (context != null && context.mounted) {
              _handleMessageClick(message, context);
            }
          });
        }
      });

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

      _authStateSub = supabase.client.auth.onAuthStateChange.listen((
        data,
      ) async {
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
              VibraLogger.info(
                'APNS token non disponibile post-login (comune su Simulatori iOS).',
                tag: 'Push',
              );
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
        VibraLogger.warning('Push bootstrap fallito: $error', tag: 'Push');
        VibraLogger.debug(stackTrace.toString(), tag: 'Push');
      }
    }
  }

  static void _handleMessageClick(RemoteMessage message, BuildContext context) {
    if (!context.mounted) return;
    final data = message.data;
    final campaignId = data['campaign_id'];
    if (campaignId != null && campaignId.isNotEmpty) {
      Supabase.instance.client
          .rpc('record_notification_open', params: {'campaign': campaignId})
          .catchError((_) {});
    }
    final type = data['type'];

    switch (type) {
      case 'chat_message':
      case 'message_request':
        final senderId = data['sender_id'];
        if (senderId != null) {
          context.push(
            '/chat',
            extra: {
              'otherUserId': senderId,
              'otherDisplayName':
                  message.notification?.title?.replaceAll(
                    'Nuovo messaggio da ',
                    '',
                  ) ??
                  'Chat',
            },
          );
        }
        break;
      case 'friend_request':
        context.push('/friends');
        break;
      case 'match':
        context.push('/social');
        break;
      case 'live_chat':
        context.push('/live');
        break;
      case 'event_alert':
      case 'artist_concert':
      case 'retention':
      case 'digest':
        final eventId = data['event_id'];
        if (eventId != null) {
          // Ideally we would fetch the event or just navigate to explore with a query
          context.push('/explore', extra: eventId);
        }
        break;
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

    VibraLogger.info(
      'Token FCM sincronizzato su Supabase (abilitato: $isPushEnabled)',
      tag: 'Push',
    );
  }

  static Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    await _authStateSub?.cancel();
    _authStateSub = null;
    _started = false;
  }
}
