import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

import 'package:flutter/foundation.dart';

import 'push_token_registration.dart';
import 'push_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/event_model.dart';
import '../../data/mappers/domain_mappers.dart';

import '../utils/logger.dart';
import 'firebase_bootstrap.dart';
import '../../data/datasources/supabase_datasource.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseBootstrap.initialize();
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
  static StreamSubscription<RemoteMessage>? _messageSub;
  static StreamSubscription<RemoteMessage>? _openedSub;
  static PushTokenRegistration? _registration;
  static AppLifecycleListener? _lifecycle;
  static Timer? _initialMessageTimer;
  static bool _started = false;

  static Future<void> initialize(SupabaseDatasource supabase) async {
    if (_started) return;
    if (!FirebaseBootstrap.isInitialized) {
      VibraLogger.warning(
        'Push bootstrap saltato: Firebase non inizializzato',
        tag: 'Push',
      );
      return;
    }

    _started = true;
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
      _messageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) {
        VibraLogger.info('Notifica tappata (app in background)!', tag: 'Push');
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          _handleMessageClick(message, context);
        }
      });

      // Install subscriptions before requesting a token: APNs may arrive late.
      _registration = PushTokenRegistration(
        readToken: () async {
          final permission = await messaging.getNotificationSettings();
          if (permission.authorizationStatus !=
                  AuthorizationStatus.authorized &&
              permission.authorizationStatus !=
                  AuthorizationStatus.provisional) {
            return null;
          }
          if (!kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) &&
              await messaging.getAPNSToken() == null) {
            return null;
          }
          return messaging.getToken();
        },
        persistToken: (token) => _persistToken(supabase, token),
        isActive: () => _started && supabase.isAuthenticated,
        onError: (error, stackTrace) => VibraLogger.warning(
          'Registrazione push in attesa; verrà ritentata',
          tag: 'Push',
        ),
      );
      _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
        try {
          if (_started && supabase.isAuthenticated && token.isNotEmpty) {
            await _persistToken(supabase, token);
          }
        } catch (error) {
          await synchronizeToken();
        }
      }, onError: (Object error) => synchronizeToken());
      _authStateSub = supabase.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn ||
            data.event == AuthChangeEvent.initialSession) {
          unawaited(synchronizeToken());
        }
      });
      _lifecycle = AppLifecycleListener(
        onResume: () {
          unawaited(synchronizeToken());
        },
      );
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null && _started) {
        _initialMessageTimer = Timer(const Duration(milliseconds: 1500), () {
          final context = AppRouter.rootNavigatorKey.currentContext;
          if (_started && context != null && context.mounted) {
            _handleMessageClick(initialMessage, context);
          }
        });
      }
      await synchronizeToken();
    } catch (error, stackTrace) {
      await dispose();
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
        final liveEventId = data['event_id'];
        context.push(
          Uri(
            path: '/live',
            queryParameters: liveEventId == null
                ? null
                : {'eventId': liveEventId},
          ).toString(),
        );
        break;
      case 'event_alert':
      case 'artist_concert':
      case 'retention':
      case 'digest':
        final eventId = data['event_id'];
        if (eventId != null) {
          unawaited(_openEvent(eventId, context));
        }
        break;
    }
  }

  static Future<void> _openEvent(String eventId, BuildContext context) async {
    try {
      final row = await Supabase.instance.client
          .from('events')
          .select()
          .eq('id', eventId)
          .maybeSingle();
      if (!context.mounted) return;
      if (row != null) {
        unawaited(
          context.push(
            '/event-detail',
            extra: EventModel.fromJson(row).toEntity(),
          ),
        );
        return;
      }
    } catch (_) {
      VibraLogger.warning('Evento della notifica non disponibile', tag: 'Push');
    }
    if (context.mounted) unawaited(context.push('/explore'));
  }

  static Future<void> _persistToken(
    SupabaseDatasource supabase,
    String token,
  ) async {
    final user = supabase.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (!_started || supabase.currentUser?.id != user.id) return;
    await PushPreferences.migrateLegacyOptOut(prefs, user.id, () async {
      await supabase.client
          .from('users')
          .update({'push_enabled': false, 'fcm_token': null})
          .eq('id', user.id);
    });

    // Supabase is authoritative: never resurrect a token after opting out.
    final profile = await supabase.client
        .from('users')
        .select('push_enabled')
        .eq('id', user.id)
        .maybeSingle();
    if (!_started || supabase.currentUser?.id != user.id || profile == null) {
      return;
    }
    final isPushEnabled = profile['push_enabled'] != false;
    await supabase.client
        .from('users')
        .update({'fcm_token': isPushEnabled ? token : null})
        .eq('id', user.id);

    VibraLogger.info(
      'Token FCM sincronizzato su Supabase (abilitato: $isPushEnabled)',
      tag: 'Push',
    );
  }

  static Future<void> synchronizeToken() async {
    await _registration?.synchronize();
  }

  static Future<void> dispose() async {
    _started = false;
    _registration?.dispose();
    _registration = null;
    _lifecycle?.dispose();
    _lifecycle = null;
    _initialMessageTimer?.cancel();
    _initialMessageTimer = null;
    await _messageSub?.cancel();
    _messageSub = null;
    await _openedSub?.cancel();
    _openedSub = null;
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    await _authStateSub?.cancel();
    _authStateSub = null;
    _started = false;
  }
}
