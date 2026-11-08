import 'app_user.dart';
import 'music_affinity.dart';

class MatchedUserPreview {
  const MatchedUserPreview({
    required this.user,
    required this.compatibility,
    required this.topArtists,
    required this.city,
    required this.attendingEvents,
    this.isFriend = false,
    this.affinity,
  });

  final AppUser user;
  final int compatibility;
  final List<String> topArtists;
  final String city;
  final int attendingEvents;
  final bool isFriend;

  /// Server-side explanation for this compatibility (null outside the
  /// affinity feed, e.g. plain people search).
  final AffinityDetails? affinity;
}
