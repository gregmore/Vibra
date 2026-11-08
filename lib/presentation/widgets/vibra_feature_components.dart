/// VIBRA feature components (spec section 25, docs/ui-architecture.md).
///
/// One import for the reusable cards of every music-social feature. Each
/// lives next to its feature's other widgets. Where the component already
/// existed under another name, the spec name is an alias (as in
/// `vibra_state_views.dart`), so there is still only one implementation.
library;

import 'affinity_explanation_card.dart';
import 'common/vibra_event_card.dart';
import 'common/vibra_user_match_card.dart';
import 'feed_widgets.dart';
import 'musical_dna_widgets.dart';

export 'affinity_explanation_card.dart' show AffinityExplanationCard;
export 'artist_discovery_widgets.dart' show ArtistRecommendationCard;
export 'circle_widgets.dart' show VibraCircleCard;
export 'common/vibra_event_card.dart' show VibraEventCard;
export 'common/vibra_user_match_card.dart' show VibraUserMatchCard;
export 'community_widgets.dart' show CommunityCard;
export 'concert_widgets.dart' show ConcertMatchCard;
export 'daily_vibe_widgets.dart' show DailyVibeCard;
export 'feed_widgets.dart' show FeedPostCard;
export 'music_radar_widgets.dart' show MusicRadarMap;
export 'music_story_widgets.dart' show MusicStoryCard, UserStoriesStrip;
export 'musical_dna_widgets.dart' show MusicalDnaPreviewCard, DnaStrip;
export 'notification_widgets.dart' show NotificationCard;
export 'same_frequency_widgets.dart' show SameFrequencyCard;
export 'taste_evolution_widgets.dart' show TasteEvolutionChart;

/// Musical DNA summary: the genre-family strip and the top families.
typedef MusicalDNAWidget = MusicalDnaPreviewCard;

/// A person with their affinity score and shared artists.
typedef MusicAffinityCard = VibraUserMatchCard;

/// Why two people match: the server's explanation of the score.
typedef WhyYouMatchCard = AffinityExplanationCard;

/// A concert or event.
typedef ConcertEventCard = VibraEventCard;

/// A post in the VIBRA Feed.
typedef MusicFeedCard = FeedPostCard;
