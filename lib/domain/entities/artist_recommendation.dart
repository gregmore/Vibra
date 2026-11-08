/// "Discover my next artist" (docs/artist-discovery.md).
enum DiscoveryBucket {
  similar,
  collaboration,
  emerging,
  underground,
  exploration,
}

/// What the user said about a recommended artist.
enum ArtistReaction {
  like('like'),
  notInterested('not_interested'),
  known('known');

  const ArtistReaction(this.wire);
  final String wire;

  static ArtistReaction? fromWire(Object? v) =>
      ArtistReaction.values.where((r) => r.wire == v).firstOrNull;
}

class ArtistRecommendation {
  const ArtistRecommendation({
    required this.artistId,
    required this.name,
    required this.bucket,
    this.imageUrl,
    this.genres = const [],
    this.popularity,
    this.followers,
    this.seedArtist,
    this.sharedGenres = const [],
    this.exploredGenre,
    this.reaction,
    this.saved = false,
  });

  final String artistId;
  final String name;
  final String? imageUrl;
  final List<String> genres;
  final int? popularity;
  final int? followers;
  final DiscoveryBucket bucket;

  /// Facts behind the recommendation.
  final String? seedArtist;
  final List<String> sharedGenres;
  final String? exploredGenre;
  final ArtistReaction? reaction;
  final bool saved;

  String get spotifyUrl => 'https://open.spotify.com/artist/$artistId';

  ArtistRecommendation copyWith({
    ArtistReaction? reaction,
    bool clearReaction = false,
    bool? saved,
  }) => ArtistRecommendation(
    artistId: artistId,
    name: name,
    imageUrl: imageUrl,
    genres: genres,
    popularity: popularity,
    followers: followers,
    bucket: bucket,
    seedArtist: seedArtist,
    sharedGenres: sharedGenres,
    exploredGenre: exploredGenre,
    reaction: clearReaction ? null : reaction ?? this.reaction,
    saved: saved ?? this.saved,
  );

  static ArtistRecommendation? fromRow(Map<String, dynamic> r) {
    final bucket = DiscoveryBucket.values
        .where((b) => b.name == r['bucket'])
        .firstOrNull;
    if (r['artist_id'] is! String || r['name'] is! String || bucket == null) {
      return null;
    }
    final reason = r['reason'] is Map ? r['reason'] as Map : const {};
    final image = r['image_url'] as String?;
    return ArtistRecommendation(
      artistId: r['artist_id'] as String,
      name: r['name'] as String,
      imageUrl: image != null && image.startsWith('https://') ? image : null,
      genres: [
        if (r['genres'] is List) ...(r['genres'] as List).whereType<String>(),
      ],
      popularity: (r['popularity'] as num?)?.toInt(),
      followers: (r['followers'] as num?)?.toInt(),
      bucket: bucket,
      seedArtist: reason['seed_artist'] as String?,
      sharedGenres: [
        if (reason['shared_genres'] is List)
          ...(reason['shared_genres'] as List).whereType<String>(),
      ],
      exploredGenre: reason['explored_genre'] as String?,
      reaction: ArtistReaction.fromWire(r['reaction']),
      saved: r['saved'] == true,
    );
  }
}

/// An artist saved for later.
class SavedArtist {
  const SavedArtist({
    required this.artistId,
    required this.name,
    this.imageUrl,
    this.liked = false,
  });
  final String artistId;
  final String name;
  final String? imageUrl;
  final bool liked;

  String get spotifyUrl => 'https://open.spotify.com/artist/$artistId';
}

class ArtistDiscoveryResult {
  const ArtistDiscoveryResult({
    this.artists = const [],
    this.emptyReason,
    this.providerUnavailable = false,
  });
  final List<ArtistRecommendation> artists;

  /// 'no_profile' when there is nothing to base recommendations on.
  final String? emptyReason;
  final bool providerUnavailable;
}
