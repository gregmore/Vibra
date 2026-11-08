import 'musical_dna.dart';

/// Profile: complete musical identity (docs/profile-identity.md).
enum ProfileSection {
  genres,
  artists,
  stats,
  savedSongs('saved_songs'),
  playlists,
  events,
  communities,
  circles,
  activity;

  const ProfileSection([this._wire]);
  final String? _wire;
  String get wire => _wire ?? name;

  static ProfileSection? fromWire(Object? v) =>
      ProfileSection.values.where((s) => s.wire == v).firstOrNull;
}

enum SectionLevel {
  public,
  connections,
  private;

  static SectionLevel fromWire(Object? v) =>
      SectionLevel.values.where((l) => l.name == v).firstOrNull ??
      SectionLevel.public;
}

typedef ProfileArtist = ({String? id, String name});
typedef ProfileSong = ({
  String title,
  String artist,
  String? artworkUrl,
  String url,
  bool spotify,
});
typedef ProfilePlaylist = ({
  String postId,
  String title,
  String? subtitle,
  String? artworkUrl,
  String? url,
  bool spotify,
});
typedef ProfileEvent = ({
  String id,
  String name,
  String? artist,
  String? venue,
  String? city,
  DateTime date,
  String status,
  String? imageUrl,
});
typedef ProfileGroup = ({String id, String name, int members, String? role});
typedef ProfileActivity = ({
  String type,
  String id,
  String? kind,
  String title,
  String? subtitle,
  DateTime at,
});

class ProfileStats {
  const ProfileStats({
    this.followers = 0,
    this.following = 0,
    this.discoveries = 0,
    this.posts = 0,
    this.communities = 0,
    this.genres = 0,
    this.diversity,
    this.concerts,
  });
  final int followers;
  final int following;
  final int discoveries;
  final int posts;
  final int communities;
  final int genres;
  final int? diversity;

  /// Owner only.
  final int? concerts;
}

class ProfileIdentity {
  const ProfileIdentity({
    required this.userId,
    required this.username,
    required this.isMe,
    this.relation = 'none',
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.memberSince,
    this.dna,
    this.sections = const {},
    this.hidden = const {},
    this.genres,
    this.artists,
    this.stats,
    this.savedSongs,
    this.playlists,
    this.events,
    this.communities,
    this.circles,
    this.activity,
  });

  final String userId;
  final String username;
  final bool isMe;

  /// 'me' | 'connection' | 'match' | 'none'.
  final String relation;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? memberSince;

  /// Null when hidden by its owner's DNA visibility.
  final MusicalDna? dna;

  /// Owner only: the level of each section.
  final Map<ProfileSection, SectionLevel> sections;

  /// Sections the viewer may not see.
  final Set<ProfileSection> hidden;

  // A null section is hidden; an empty one is simply empty.
  final List<String>? genres;
  final List<ProfileArtist>? artists;
  final ProfileStats? stats;
  final List<ProfileSong>? savedSongs;
  final List<ProfilePlaylist>? playlists;
  final List<ProfileEvent>? events;
  final List<ProfileGroup>? communities;
  final List<ProfileGroup>? circles;
  final List<ProfileActivity>? activity;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  SectionLevel levelOf(ProfileSection s) => sections[s] ?? SectionLevel.public;

  static List<Map<String, dynamic>> _list(Object? v) => [
    for (final x in (v is List ? v : const []))
      if (x is Map) Map<String, dynamic>.from(x),
  ];

  static bool _https(Object? v) => v is String && v.startsWith('https://');

  static ProfileIdentity? fromJson(Object? raw) {
    if (raw is! Map || raw['user_id'] is! String) return null;
    final r = Map<String, dynamic>.from(raw);
    int n(Object? v) => (v as num?)?.toInt() ?? 0;
    final stats = r['stats'] is Map ? r['stats'] as Map : null;
    return ProfileIdentity(
      userId: r['user_id'] as String,
      username: r['username']?.toString() ?? 'user',
      isMe: r['is_me'] == true,
      relation: r['relation']?.toString() ?? 'none',
      displayName: r['display_name'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      bio: r['bio'] as String?,
      memberSince: DateTime.tryParse('${r['member_since']}'),
      dna: MusicalDna.fromJson(r['dna']),
      sections: {
        if (r['sections'] is Map)
          for (final e in (r['sections'] as Map).entries)
            ?ProfileSection.fromWire(e.key): SectionLevel.fromWire(e.value),
      },
      hidden: {
        for (final h in (r['hidden'] is List ? r['hidden'] as List : const []))
          ?ProfileSection.fromWire(h),
      },
      genres: r['genres'] is List
          ? (r['genres'] as List).whereType<String>().toList()
          : null,
      artists: r['artists'] is List
          ? [
              for (final a in _list(r['artists']))
                if (a['name'] is String)
                  (id: a['id'] as String?, name: a['name'] as String),
            ]
          : null,
      stats: stats == null
          ? null
          : ProfileStats(
              followers: n(stats['followers']),
              following: n(stats['following']),
              discoveries: n(stats['discoveries']),
              posts: n(stats['posts']),
              communities: n(stats['communities']),
              genres: n(stats['genres']),
              diversity: (stats['diversity'] as num?)?.toInt(),
              concerts: (stats['concerts'] as num?)?.toInt(),
            ),
      savedSongs: r['saved_songs'] is List
          ? [
              for (final s in _list(r['saved_songs']))
                if (s['title'] is String && _https(s['external_url']))
                  (
                    title: s['title'] as String,
                    artist: s['artist']?.toString() ?? '',
                    artworkUrl: _https(s['artwork_url'])
                        ? s['artwork_url'] as String
                        : null,
                    url: s['external_url'] as String,
                    spotify: s['provider'] == 'spotify',
                  ),
            ]
          : null,
      playlists: r['playlists'] is List
          ? [
              for (final p in _list(r['playlists']))
                if (p['post_id'] is String && p['title'] is String)
                  (
                    postId: p['post_id'] as String,
                    title: p['title'] as String,
                    subtitle: p['subtitle'] as String?,
                    artworkUrl: _https(p['artwork_url'])
                        ? p['artwork_url'] as String
                        : null,
                    url: _https(p['external_url'])
                        ? p['external_url'] as String
                        : null,
                    spotify: p['provider'] == 'spotify',
                  ),
            ]
          : null,
      events: r['events'] is List
          ? [
              for (final e in _list(r['events']))
                if (e['id'] is String &&
                    e['name'] is String &&
                    DateTime.tryParse('${e['event_date']}') != null)
                  (
                    id: e['id'] as String,
                    name: e['name'] as String,
                    artist: e['artist_name'] as String?,
                    venue: e['venue_name'] as String?,
                    city: e['city'] as String?,
                    date: DateTime.parse('${e['event_date']}'),
                    status: e['status']?.toString() ?? 'interested',
                    imageUrl: _https(e['image_url'])
                        ? e['image_url'] as String
                        : null,
                  ),
            ]
          : null,
      communities: r['communities'] is List
          ? [
              for (final c in _list(r['communities']))
                if (c['id'] is String && c['name'] is String)
                  (
                    id: c['id'] as String,
                    name: c['name'] as String,
                    members: n(c['member_count']),
                    role: c['role'] as String?,
                  ),
            ]
          : null,
      circles: r['circles'] is List
          ? [
              for (final c in _list(r['circles']))
                if (c['id'] is String && c['name'] is String)
                  (
                    id: c['id'] as String,
                    name: c['name'] as String,
                    members: n(c['members']),
                    role: null,
                  ),
            ]
          : null,
      activity: r['activity'] is List
          ? [
              for (final a in _list(r['activity']))
                if (a['id'] is String &&
                    a['type'] is String &&
                    DateTime.tryParse('${a['at']}') != null)
                  (
                    type: a['type'] as String,
                    id: a['id'] as String,
                    kind: a['kind'] as String?,
                    title: a['title']?.toString() ?? '',
                    subtitle: a['subtitle'] as String?,
                    at: DateTime.parse('${a['at']}'),
                  ),
            ]
          : null,
    );
  }
}
