/// Eccezione generica del server (Supabase, API esterne).
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;

  const ServerException({
    required this.message,
    this.statusCode,
    this.endpoint,
  });

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode, endpoint: $endpoint)';
}

/// Eccezione di cache locale (SharedPreferences, lettura/scrittura fallita).
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Eccezione di autenticazione (token scaduto, login fallito, permessi negati).
class AuthException implements Exception {
  final String message;
  final String? errorCode;

  const AuthException({required this.message, this.errorCode});

  @override
  String toString() =>
      'AuthException(message: $message, errorCode: $errorCode)';
}

/// Eccezione specifica per errori dell'API Spotify.
class SpotifyException implements Exception {
  final String message;
  final int? statusCode;

  /// Se true, indica che il token è scaduto e va refreshato.
  final bool isTokenExpired;

  const SpotifyException({
    required this.message,
    this.statusCode,
    this.isTokenExpired = false,
  });

  @override
  String toString() =>
      'SpotifyException(message: $message, statusCode: $statusCode, isTokenExpired: $isTokenExpired)';
}

/// Eccezione di rete (nessuna connessione, timeout).
class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Eccezione per permessi negati (localizzazione, notifiche, etc.).
class PermissionException implements Exception {
  final String message;
  final String permissionType;

  const PermissionException({
    required this.message,
    required this.permissionType,
  });

  @override
  String toString() =>
      'PermissionException(message: $message, type: $permissionType)';
}

/// Eccezione lanciata quando una configurazione obbligatoria manca.
class ConfigurationException implements Exception {
  final String message;

  const ConfigurationException({required this.message});

  @override
  String toString() => 'ConfigurationException(message: $message)';
}
