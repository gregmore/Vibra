import '../entities/compatibility_result.dart';
import '../entities/music_profile.dart';

/// Algoritmo match utenti:
/// compatibility =
///   (artisti_in_comune / top_50_artisti * 100 * 0.60) +
///   (generi_in_comune  / generi_totali  * 100 * 0.40)
class CalculateUserCompatibilityUseCase {
  const CalculateUserCompatibilityUseCase();

  CompatibilityResult call({
    required MusicProfile left,
    required MusicProfile right,
  }) {
    final leftArtistIds = left.topArtists.map((e) => e.id).toSet();
    final rightArtistIds = right.topArtists.map((e) => e.id).toSet();
    final sharedArtists = leftArtistIds.intersection(rightArtistIds).length;

    final leftGenres = left.topGenres.map((e) => e.genre.toLowerCase()).toSet();
    final rightGenres = right.topGenres
        .map((e) => e.genre.toLowerCase())
        .toSet();
    final sharedGenres = leftGenres.intersection(rightGenres).length;

    final artistBase = left.topArtists.isEmpty ? 1 : left.topArtists.length;
    final genreUniverse = {...leftGenres, ...rightGenres}.length;

    final sharedArtistsPercentage = (sharedArtists / artistBase) * 100;
    final sharedGenresPercentage =
        (sharedGenres / (genreUniverse == 0 ? 1 : genreUniverse)) * 100;

    final total =
        (sharedArtistsPercentage * 0.60) + (sharedGenresPercentage * 0.40);

    return CompatibilityResult(
      percentage: double.parse(total.toStringAsFixed(2)),
      sharedArtistsPercentage: double.parse(
        sharedArtistsPercentage.toStringAsFixed(2),
      ),
      sharedGenresPercentage: double.parse(
        sharedGenresPercentage.toStringAsFixed(2),
      ),
    );
  }
}
