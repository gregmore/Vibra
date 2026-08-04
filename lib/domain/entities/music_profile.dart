class MusicArtistPreference {
  const MusicArtistPreference({
    required this.id,
    required this.name,
    required this.score,
  });

  final String id;
  final String name;
  final int score;
}

class MusicTrackPreference {
  const MusicTrackPreference({
    required this.id,
    required this.name,
    this.artist,
    required this.score,
  });

  final String id;
  final String name;
  final String? artist;
  final int score;
}

class GenrePreference {
  const GenrePreference({required this.genre, required this.weight});

  final String genre;
  final double weight;
}

/// Entità pura del profilo musicale.
class MusicProfile {
  const MusicProfile({
    required this.id,
    required this.userId,
    required this.topArtists,
    required this.topTracks,
    required this.topGenres,
    this.lastSyncedAt,
  });

  final String id;
  final String userId;
  final List<MusicArtistPreference> topArtists;
  final List<MusicTrackPreference> topTracks;
  final List<GenrePreference> topGenres;
  final DateTime? lastSyncedAt;
}
