import '../../core/errors/exceptions.dart';
import '../../core/services/spotify_token_storage.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/music_profile.dart';
import '../../domain/repositories/spotify_repository.dart';
import '../datasources/spotify_datasource.dart';
import '../models/spotify/spotify_artist_model.dart';
import '../models/spotify/spotify_track_model.dart';

/// Repository concreto per integrazione Spotify.
/// - Gestisce OAuth PKCE
/// - Scarica top artisti/brani/playlists
/// - Calcola generi e score
class SpotifyRepositoryImpl implements SpotifyRepository {
  SpotifyRepositoryImpl(this._datasource, this._tokenStorage);

  final SpotifyDatasource _datasource;
  final SpotifyTokenStorage _tokenStorage;

  /// Avvia OAuth e salva token in secure storage.
  @override
  Future<void> authenticate() async {
    final tokens = await _datasource.authorize();
    await _tokenStorage.saveAccessToken(tokens['access_token']!);
    if (tokens['refresh_token'] != null) {
      await _tokenStorage.saveRefreshToken(tokens['refresh_token']!);
    }
  }

  /// Carica token da storage e li imposta nel datasource.
  @override
  Future<void> loadTokensIntoDatasource() async {
    final access = await _tokenStorage.readAccessToken();
    final refresh = await _tokenStorage.readRefreshToken();
    if (access == null) return;
    _datasource.setTokens(accessToken: access, refreshToken: refresh);
  }

  /// Sincronizza profilo musicale (top artisti/brani + generi aggregati) nel formato JSONB richiesto.
  @override
  Future<MusicProfile> buildMusicProfilePayload({
    required String userId,
  }) async {
    await loadTokensIntoDatasource();

    // Top artists
    final topArtistsPaged = await _datasource.getTopArtists(limit: 50);
    final artists = _datasource.parseArtists(topArtistsPaged);

    // Top tracks
    final topTracksPaged = await _datasource.getTopTracks(limit: 50);
    final tracks = _datasource.parseTracks(topTracksPaged);

    // Playlists (non salviamo tutte nel music_profile per ora, ma la chiamata resta nel flow)
    await _datasource.getPlaylists(limit: 50);

    final topArtistsJson = _buildArtistsJson(artists);
    final topTracksJson = _buildTracksJson(tracks);
    final topGenresJson = _buildGenresJson(artists);

    VibraLogger.info(
      'Profilo musicale costruito: artists=${topArtistsJson.length}, tracks=${topTracksJson.length}, genres=${topGenresJson.length}',
      tag: 'SpotifyRepo',
    );

    return MusicProfile(
      id: '00000000-0000-0000-0000-000000000000',
      userId: userId,
      topArtists: topArtistsJson
          .map(
            (item) => MusicArtistPreference(
              id: item['id'].toString(),
              name: item['name'].toString(),
              score: (item['score'] as num).toInt(),
            ),
          )
          .toList(growable: false),
      topTracks: topTracksJson
          .map(
            (item) => MusicTrackPreference(
              id: item['id'].toString(),
              name: item['name'].toString(),
              artist: item['artist']?.toString(),
              score: (item['score'] as num).toInt(),
            ),
          )
          .toList(growable: false),
      topGenres: topGenresJson
          .map(
            (item) => GenrePreference(
              genre: item['genre'].toString(),
              weight: (item['weight'] as num).toDouble(),
            ),
          )
          .toList(growable: false),
      lastSyncedAt: DateTime.now().toUtc(),
    );
  }

  List<Map<String, dynamic>> _buildArtistsJson(
    List<SpotifyArtistModel> artists,
  ) {
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < artists.length; i++) {
      final a = artists[i];
      final position = i + 1;
      final score = 100 - (position - 1) * 1; // 1->100, 50->51
      out.add({'id': a.id, 'name': a.name, 'score': score.clamp(0, 100)});
    }
    return out;
  }

  List<Map<String, dynamic>> _buildTracksJson(List<SpotifyTrackModel> tracks) {
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < tracks.length; i++) {
      final t = tracks[i];
      final position = i + 1;
      final score = 100 - (position - 1) * 1;
      out.add({
        'id': t.id,
        'name': t.name,
        'artist': t.artists.isNotEmpty ? t.artists.first.name : null,
        'score': score.clamp(0, 100),
      });
    }
    return out;
  }

  List<Map<String, dynamic>> _buildGenresJson(
    List<SpotifyArtistModel> artists,
  ) {
    final counts = <String, int>{};
    for (final a in artists) {
      for (final g in a.genres) {
        final key = g.trim().toLowerCase();
        if (key.isEmpty) continue;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Normalizza su 0..1 (peso)
    final max = sorted.isEmpty ? 1 : sorted.first.value;
    return sorted
        .map((e) {
          final weight = e.value / max;
          return {
            'genre': e.key,
            'weight': double.parse(weight.toStringAsFixed(4)),
          };
        })
        .toList(growable: false);
  }

  /// Refresh token esplicito (utile quando Spotify restituisce 401).
  @override
  Future<void> refreshTokenIfPossible() async {
    final refresh = await _tokenStorage.readRefreshToken();
    if (refresh == null) {
      throw const AuthException(message: 'Refresh token Spotify mancante');
    }

    // Il datasource usa il refresh token interno; lo aggiorniamo prima.
    final access = await _tokenStorage.readAccessToken();
    if (access != null) {
      _datasource.setTokens(accessToken: access, refreshToken: refresh);
    }

    final newAccess = await _datasource.refreshAccessToken();
    await _tokenStorage.saveAccessToken(newAccess);
  }
}
