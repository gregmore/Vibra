import '../constants/storage_keys.dart';
import 'secure_storage_service.dart';

/// Storage sicuro dedicato ai token Spotify.
class SpotifyTokenStorage {
  SpotifyTokenStorage(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: StorageKeys.spotifyAccessToken, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: StorageKeys.spotifyRefreshToken,
      value: token,
    );
  }

  Future<String?> readAccessToken() async {
    return _secureStorage.read(key: StorageKeys.spotifyAccessToken);
  }

  Future<String?> readRefreshToken() async {
    return _secureStorage.read(key: StorageKeys.spotifyRefreshToken);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: StorageKeys.spotifyAccessToken);
    await _secureStorage.delete(key: StorageKeys.spotifyRefreshToken);
  }
}

