import 'app_user.dart';

class MatchedUserPreview {
  const MatchedUserPreview({
    required this.user,
    required this.compatibility,
    required this.topArtists,
    required this.city,
    required this.attendingEvents,
    this.isFriend = false,
  });

  final AppUser user;
  final int compatibility;
  final List<String> topArtists;
  final String city;
  final int attendingEvents;
  final bool isFriend;
}
