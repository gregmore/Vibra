import '../../core/errors/offline.dart';
import '../../l10n/app_localizations.dart';

/// Converts service errors into localized, actionable text. Unknown diagnostic
/// details stay in logs, never in the interface (SQL, tokens or stack traces).
String userFacingError(AppLocalizations l10n, Object? error) {
  final message = (error?.toString() ?? '').toLowerCase();
  if (message.contains('registrazione completata')) {
    return l10n.authConfirmEmail;
  }
  if (message.contains('email_not_confirmed') ||
      message.contains('non è stato ancora confermato')) {
    return l10n.authEmailNotConfirmed;
  }
  if (message.contains('invalid_credentials') ||
      message.contains('invalid login credentials') ||
      message.contains('credenziali non valide')) {
    return l10n.authInvalidCredentials;
  }
  if (message.contains('provider is not enabled') ||
      message.contains('non è configurato/abilitato')) {
    return l10n.authProviderUnavailable;
  }
  if (message.contains('user_already_exists') ||
      message.contains('user already registered') ||
      message.contains('email_exists')) {
    return l10n.authEmailAlreadyRegistered;
  }
  if (message.contains('weak_password') ||
      message.contains('password should be at least')) {
    return l10n.authWeakPassword;
  }
  if (message.contains('spotify_temporarily_unavailable')) {
    return l10n.spotifyUnavailableBody;
  }
  if (message.contains('spotify_access_not_granted')) {
    return l10n.spotifyAccessNotGranted;
  }
  if (message.contains('spotify_token_exchange_failed') ||
      message.contains('spotify_authorization_expired') ||
      message.contains('scambio token fallito')) {
    return l10n.spotifyConnectFailed;
  }
  if (message.contains('spotify_rate_limited')) {
    return l10n.spotifyRateLimited;
  }
  if (message.contains('spotify_not_connected')) {
    return l10n.musicReconnectBody;
  }
  if (message.contains('session_changed') ||
      message.contains('sessione è cambiata') ||
      message.contains('jwt expired') ||
      message.contains('authentication required')) {
    return l10n.errorSessionChanged;
  }
  if (message.contains('rate limit') ||
      message.contains('rate_limit') ||
      message.contains('too many requests')) {
    return l10n.errorRateLimited;
  }
  // One definition of "offline" for the whole app (core/errors/offline.dart);
  // the looser words stay for messages that only describe the failure.
  if (isOfflineError(error) ||
      message.contains('network') ||
      message.contains('connection') ||
      message.contains('timeout')) {
    return l10n.errorNetwork;
  }
  return l10n.errorActionFailed;
}

bool isRegistrationConfirmation(String? message) =>
    message?.toLowerCase().contains('registrazione completata') ?? false;
