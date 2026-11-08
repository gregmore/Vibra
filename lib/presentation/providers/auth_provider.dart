import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/services/cache_service.dart';
import 'core_providers.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsign;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'app_state_providers.dart';
import 'spotify_auth_provider.dart';
import 'location_provider.dart';
import 'live_events_provider.dart';
import 'public_users_provider.dart';
import 'public_friends_provider.dart';
import 'direct_message_permission_provider.dart';

enum GeneralAuthStatus { idle, loading, authenticated, error }

class GeneralAuthState {
  final GeneralAuthStatus status;
  final String? errorMessage;
  final User? user;

  const GeneralAuthState({required this.status, this.errorMessage, this.user});

  const GeneralAuthState.idle()
    : status = GeneralAuthStatus.idle,
      errorMessage = null,
      user = null;

  const GeneralAuthState.loading()
    : status = GeneralAuthStatus.loading,
      errorMessage = null,
      user = null;

  const GeneralAuthState.authenticated(User u)
    : status = GeneralAuthStatus.authenticated,
      errorMessage = null,
      user = u;

  const GeneralAuthState.error(String message)
    : status = GeneralAuthStatus.error,
      errorMessage = message,
      user = null;
}

class GeneralAuthNotifier extends StateNotifier<GeneralAuthState> {
  final Ref _ref;

  GeneralAuthNotifier(this._ref) : super(const GeneralAuthState.idle()) {
    // Sincronizza lo stato iniziale con Supabase
    final currentUser = _ref.read(supabaseDatasourceProvider).currentUser;
    if (currentUser != null) {
      state = GeneralAuthState.authenticated(currentUser);
    }
  }

  bool _isGoogleSignInInitialized = false;

  Future<void> _prepareSignIn() async {
    final auth = _ref.read(supabaseDatasourceProvider).client.auth;
    final previousTokens = _ref.read(spotifyTokenStorageProvider);
    try {
      if (auth.currentSession != null) {
        await auth.signOut(scope: SignOutScope.local);
      }
    } finally {
      // A failed or cancelled new login must never restore the previous user.
      await Future.wait([previousTokens.clear(), clearLocalState()]);
    }
  }

  /// Pulisce forzatamente tutto lo stato locale (Riverpod, Cache, Spotify, Google SignIn).
  /// Deve essere chiamato al logout e PRIMA di ogni nuovo login per garantire l'isolamento degli account.
  Future<void> clearLocalState() async {
    try {
      await gsign.GoogleSignIn.instance.signOut();
    } catch (e) {
      VibraLogger.warning('Errore durante Google Sign Out: $e');
    }

    _ref.invalidate(myEventsProvider);
    _ref.invalidate(allEventsProvider);
    _ref.invalidate(matchedUsersProvider);
    _ref.invalidate(publicUsersProvider);
    _ref.invalidate(publicFriendsProvider);
    _ref.invalidate(publicConnectionProfilesProvider);
    _ref.invalidate(directMessagePermissionProvider);
    _ref.invalidate(pendingFriendshipsProvider);
    _ref.invalidate(directMessagesProvider);
    _ref.invalidate(conversationsProvider);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(userFollowStatsProvider);
    _ref.invalidate(userProfileDetailProvider);
    _ref.invalidate(userLocationProvider);
    _ref.invalidate(liveMessagesProvider);
    _ref.invalidate(liveEventsProvider);
    _ref.invalidate(liveAttendanceProvider);
    _ref.invalidate(myProfileProvider);
    _ref.invalidate(myMusicProfileProvider);
    _ref.invalidate(settingsStateProvider);
    _ref.invalidate(digestFrequencyProvider);
    _ref.invalidate(pushEnabledProvider);
    _ref.invalidate(presenceProvider);
    _ref.invalidate(spotifyAuthProvider);

    try {
      // Run every cleanup even if one storage backend reports an error.
      await Future.wait([
        _ref.read(spotifyTokenStorageProvider).clear(),
        CacheService.clearAll(),
        DefaultCacheManager().emptyCache(),
      ]);
      await _ref.read(localeStateProvider.notifier).setLocale(null);
    } finally {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      VibraLogger.clear();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const GeneralAuthState.loading();
      await _prepareSignIn();
      final supabase = _ref.read(supabaseDatasourceProvider);

      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];

      if (!_isGoogleSignInInitialized) {
        await gsign.GoogleSignIn.instance.initialize(
          serverClientId: webClientId,
          clientId: iosClientId,
        );
        _isGoogleSignInInitialized = true;
      }

      final googleUser = await gsign.GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      // Access token is optional but useful for Supabase
      final authz = await googleUser.authorizationClient.authorizationForScopes(
        ['email', 'profile', 'openid'],
      );
      final accessToken = authz?.accessToken;

      if (idToken == null) {
        throw Exception('Impossibile ottenere l\'ID token da Google');
      }

      await supabase.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      VibraLogger.error('Errore durante il login con Google', error: e);
      String errorMessage = e.toString();
      if (e is AuthApiException) {
        if (e.message.contains('provider is not enabled')) {
          errorMessage =
              'Google Sign-In non è configurato/abilitato nel tuo progetto Supabase di produzione. Abilitalo da Authentication -> Providers -> Google.';
        } else {
          errorMessage = e.message;
        }
      }
      state = GeneralAuthState.error(errorMessage);
    }
  }

  Future<void> signInWithApple() async {
    try {
      state = const GeneralAuthState.loading();
      await _prepareSignIn();
      final supabase = _ref.read(supabaseDatasourceProvider);

      final rawNonce = supabase.client.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Token Apple mancante.');
      }

      await supabase.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } catch (e) {
      VibraLogger.error('Errore durante il login con Apple', error: e);
      String errorMessage = e.toString();
      if (e is AuthApiException) {
        if (e.message.contains('provider is not enabled')) {
          errorMessage =
              'Apple Sign-In non è configurato/abilitato nel tuo progetto Supabase di produzione. Abilitalo da Authentication -> Providers -> Apple.';
        } else {
          errorMessage = e.message;
        }
      }
      state = GeneralAuthState.error(errorMessage);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = const GeneralAuthState.loading();
      await _prepareSignIn();
      final supabase = _ref.read(supabaseDatasourceProvider);

      final response = await supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = GeneralAuthState.authenticated(response.user!);
      } else {
        state = const GeneralAuthState.error('Autenticazione fallita');
      }
    } catch (e) {
      VibraLogger.error('Errore durante il login con Email', error: e);
      String errorMessage = e.toString();
      if (e is AuthApiException) {
        if (e.code == 'email_not_confirmed') {
          errorMessage =
              'L\'indirizzo e-mail non è stato ancora confermato. Controlla la tua casella di posta per attivare l\'account!';
        } else if (e.code == 'invalid_credentials') {
          errorMessage =
              'Credenziali non valide. Controlla l\'indirizzo e-mail e la password inseriti.';
        } else {
          errorMessage = e.message;
        }
      }
      state = GeneralAuthState.error(errorMessage);
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String username, {
    required bool ageConfirmed,
  }) async {
    try {
      state = const GeneralAuthState.loading();
      await _prepareSignIn();
      final supabase = _ref.read(supabaseDatasourceProvider);

      final response = await supabase.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': username,
          'age_confirmed_18': ageConfirmed,
          'age_confirmed_at': DateTime.now().toUtc().toIso8601String(),
        },
      );

      if (response.user != null) {
        if (response.session == null) {
          state = const GeneralAuthState.error(
            'Registrazione completata con successo! Ti abbiamo inviato una e-mail di conferma. Controlla la tua casella di posta prima di effettuare l\'accesso.',
          );
        } else {
          state = GeneralAuthState.authenticated(response.user!);
        }
      } else {
        state = const GeneralAuthState.error('Registrazione fallita');
      }
    } catch (e) {
      VibraLogger.error('Errore durante la registrazione con Email', error: e);
      String errorMessage = e.toString();
      if (e is AuthApiException) {
        errorMessage = e.message;
      }
      state = GeneralAuthState.error(errorMessage);
    }
  }

  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    try {
      state = const GeneralAuthState.loading();
      final supabase = _ref.read(supabaseDatasourceProvider);
      final previousTokens = _ref.read(spotifyTokenStorageProvider);

      final user = supabase.currentUser;
      if (user != null) {
        try {
          await supabase.client
              .from('users')
              .update({'fcm_token': null})
              .eq('id', user.id);
          VibraLogger.info('Token FCM rimosso da Supabase su logout');
        } catch (e) {
          VibraLogger.warning(
            'Impossibile rimuovere token FCM su Supabase durante il logout: $e',
          );
        }
      }

      try {
        await supabase.client.auth.signOut(scope: scope);
      } finally {
        await Future.wait([previousTokens.clear(), clearLocalState()]);
      }
      state = const GeneralAuthState.idle();
    } catch (e) {
      VibraLogger.error('Errore durante il logout', error: e);
      state = GeneralAuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      state = const GeneralAuthState.loading();
      final supabase = _ref.read(supabaseDatasourceProvider);
      final userId = supabase.currentUser?.id;
      if (userId == null) {
        throw const AuthException('Authentication required');
      }

      // Storage cleanup precedes Auth deletion on the server. Only its explicit
      // completion acknowledgement means the account was actually erased.
      final response = await supabase.client.functions.invoke('delete-account');
      if (response.status != 200 ||
          response.data is! Map ||
          response.data['deleted'] != true) {
        throw const AuthException('Account deletion was not confirmed');
      }

      // A response for the previous account must not sign out a new one.
      if (supabase.currentUser?.id == userId) {
        try {
          await clearLocalState();
        } catch (error) {
          // The server has already erased the account. A cache/plugin failure
          // must not leave its session active or suggest retrying the deletion.
          VibraLogger.warning('Pulizia locale dopo eliminazione: $error');
        }

        if (supabase.currentUser?.id == userId) {
          try {
            // Supabase removes the local session before contacting the server,
            // where this account's sessions have already been revoked.
            await supabase.client.auth.signOut(scope: SignOutScope.local);
          } catch (error) {
            VibraLogger.warning('Logout dopo eliminazione: $error');
          }
        }
      }
      final currentUser = supabase.currentUser;
      state = currentUser == null
          ? const GeneralAuthState.idle()
          : GeneralAuthState.authenticated(currentUser);
    } catch (e) {
      VibraLogger.error(
        'Errore durante l\'eliminazione dell\'account',
        error: e,
      );
      state = GeneralAuthState.error(e.toString());
      rethrow;
    }
  }
}

final generalAuthProvider =
    StateNotifierProvider<GeneralAuthNotifier, GeneralAuthState>((ref) {
      return GeneralAuthNotifier(ref);
    });
