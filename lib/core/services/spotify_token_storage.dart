import '../constants/storage_keys.dart';
import 'secure_storage_service.dart';

/// Storage sicuro dedicato ai token Spotify.
class SpotifyTokenStorage {
  SpotifyTokenStorage(this._secureStorage, {required this.namespace});

  final SecureStorageService _secureStorage;
  final String namespace;

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: '${StorageKeys.spotifyAccessToken}_$namespace',
      value: token,
    );
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: '${StorageKeys.spotifyRefreshToken}_$namespace',
      value: token,
    );
  }

  Future<String?> readAccessToken() async {
    return _secureStorage.read(
      key: '${StorageKeys.spotifyAccessToken}_$namespace',
    );
  }

  Future<String?> readRefreshToken() async {
    return _secureStorage.read(
      key: '${StorageKeys.spotifyRefreshToken}_$namespace',
    );
  }

  Future<void> clear() async {
    await _secureStorage.delete(
      key: '${StorageKeys.spotifyAccessToken}_$namespace',
    );
    await _secureStorage.delete(
      key: '${StorageKeys.spotifyRefreshToken}_$namespace',
    );
    await _secureStorage.delete(key: StorageKeys.spotifyAccessToken);
    await _secureStorage.delete(key: StorageKeys.spotifyRefreshToken);
  }
}
