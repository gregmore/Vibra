// Classi Failure per gestione errori funzionale (pattern Either).
// Ogni failure corrisponde a un tipo di errore nel domain layer.

/// Classe base per tutti i failure.
sealed class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

/// Errore dal server (API call fallita, risposta inattesa).
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Errore di cache locale.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Errore di autenticazione.
class AuthFailure extends Failure {
  final String? errorCode;
  const AuthFailure({required super.message, this.errorCode});
}

/// Errore specifico Spotify.
class SpotifyFailure extends Failure {
  final bool isTokenExpired;
  const SpotifyFailure({
    required super.message,
    super.statusCode,
    this.isTokenExpired = false,
  });
}

/// Errore di connessione di rete.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Errore di permessi (GPS, notifiche, etc.).
class PermissionFailure extends Failure {
  final String permissionType;
  const PermissionFailure({
    required super.message,
    required this.permissionType,
  });
}
