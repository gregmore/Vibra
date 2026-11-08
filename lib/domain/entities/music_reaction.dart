import 'community.dart' show CommunityReactions;

/// Reactions (docs/track-reactions.md). When someone shares a song, others
/// react with dedicated musical reactions; everything else keeps the
/// general set. The server enforces which set applies to which content.
abstract final class MusicReactions {
  /// For song shares: Daily Vibes, "Now listening" stories, feed posts about
  /// a track, community music posts.
  static const track = [
    'fire',
    'obsessed',
    'underrated',
    'classic',
    'new_discovery',
    'on_repeat',
  ];

  /// For everything else.
  static const general = CommunityReactions.all;

  static const emoji = {
    ...CommunityReactions.emoji,
    'obsessed': '😍',
    'underrated': '💎',
    'classic': '🏆',
    'new_discovery': '✨',
    'on_repeat': '🔁',
  };

  static List<String> forContent({required bool song}) =>
      song ? track : general;

  /// The reaction that suggests saving the song to Discoveries.
  static const discovery = 'new_discovery';
}

final _songLink = RegExp(
  r'^https://(open\.spotify\.com/track/|music\.apple\.com/|music\.youtube\.com/|(www\.)?youtube\.com/|youtu\.be/|soundcloud\.com/|[a-z0-9-]+\.bandcamp\.com/)',
  caseSensitive: false,
);

/// Same rule as public.is_song_link: a link to a song on a supported
/// provider (community music posts).
bool isSongLink(String? url) => url != null && _songLink.hasMatch(url);

/// Where a song in Discoveries was found.
enum DiscoverySource {
  vibe('vibe'),
  story('story'),
  post('post'),
  community('community');

  const DiscoverySource(this.wire);
  final String wire;

  static DiscoverySource from(Object? v) => DiscoverySource.values.firstWhere(
    (s) => s.wire == v,
    orElse: () => DiscoverySource.vibe,
  );
}
