/// Utility per mappare i generi (es. da Spotify) a categorie compatibili con Ticketmaster
class GenreMapper {
  GenreMapper._();

  /// Normalizza un genere Spotify (spesso molto specifico come "italian hip hop")
  /// a un macro-genere di Ticketmaster (es. "Hip-Hop/Rap")
  static String mapSpotifyToTicketmaster(String spotifyGenre) {
    final s = spotifyGenre.toLowerCase();

    if (s.contains('hip hop') || s.contains('rap') || s.contains('trap')) {
      return 'Hip-Hop/Rap';
    }
    if (s.contains('rock') || s.contains('metal') || s.contains('punk')) {
      return 'Rock';
    }
    if (s.contains('pop')) {
      return 'Pop';
    }
    if (s.contains('house') ||
        s.contains('techno') ||
        s.contains('edm') ||
        s.contains('electronic')) {
      return 'Dance/Electronic';
    }
    if (s.contains('jazz') || s.contains('blues')) {
      return 'Jazz/Blues';
    }
    if (s.contains('classical')) {
      return 'Classical';
    }
    if (s.contains('country')) {
      return 'Country';
    }
    if (s.contains('reggae') || s.contains('dancehall')) {
      return 'Reggae';
    }
    if (s.contains('r&b') || s.contains('soul')) {
      return 'R&B';
    }

    // Se non troviamo match chiari, restituiamo il genere originale normalizzato
    // (Ticketmaster potrebbe comunque usarlo per query generiche via keyword)
    return spotifyGenre;
  }
}
