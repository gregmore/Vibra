import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../core/errors/exceptions.dart';
import '../../domain/entities/artist_recommendation.dart';
import 'supabase_datasource.dart';

/// "Discover my next artist" (docs/artist-discovery.md).
class SupabaseArtistDiscoveryDatasource {
  const SupabaseArtistDiscoveryDatasource(this._supabase);

  final SupabaseDatasource _supabase;

  List<ArtistRecommendation> _parse(Object? raw) => [
    for (final r in (raw is List ? raw : const []))
      if (r is Map) ?ArtistRecommendation.fromRow(Map<String, dynamic>.from(r)),
  ];

  Future<ArtistDiscoveryResult> recommendations({bool refresh = false}) async {
    if (_supabase.currentUser == null) {
      throw const AuthException(message: 'Utente non autenticato');
    }
    try {
      final response = await _supabase.client.functions.invoke(
        'discover-artists',
        body: {'action': 'get', 'refresh': refresh},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return ArtistDiscoveryResult(
        artists: _parse(data['artists']),
        emptyReason: data['empty_reason'] as String?,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      if (e.status == 503 && details is Map) {
        // Spotify unavailable: keep showing what was already recommended.
        return ArtistDiscoveryResult(
          artists: _parse(details['artists']),
          providerUnavailable: true,
        );
      }
      throw ServerException(
        message: details is Map ? '${details['error']}' : 'discovery_failed',
        statusCode: e.status,
        endpoint: 'discover-artists',
      );
    }
  }

  /// reaction: null clears it; saved: null keeps it.
  Future<void> feedback(
    String artistId, {
    ArtistReaction? reaction,
    bool? saved,
  }) => _supabase.client.rpc(
    'set_artist_feedback',
    params: {
      'p_artist': artistId,
      'p_reaction': reaction?.wire,
      'p_saved': saved,
    },
  );

  Future<void> markShown(List<String> artistIds) => artistIds.isEmpty
      ? Future.value()
      : _supabase.client.rpc(
          'mark_artist_recommendations_shown',
          params: {'p_artists': artistIds.take(50).toList()},
        );

  Future<List<SavedArtist>> saved() async {
    final user = _supabase.currentUser;
    if (user == null) return const [];
    final rows = await _supabase.client
        .from('artist_feedback')
        .select('artist_id, artist_name, image_url, reaction')
        .eq('user_id', user.id)
        .eq('saved', true)
        .order('updated_at', ascending: false)
        .limit(500);
    return [
      for (final r in rows)
        if (r['artist_id'] is String && r['artist_name'] is String)
          SavedArtist(
            artistId: r['artist_id'] as String,
            name: r['artist_name'] as String,
            imageUrl: r['image_url'] as String?,
            liked: r['reaction'] == 'like',
          ),
    ];
  }
}
