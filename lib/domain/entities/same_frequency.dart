import 'music_affinity.dart';

/// One upcoming event two people both saved (only shared when both opted in).
class SharedEvent {
  const SharedEvent({
    required this.id,
    required this.name,
    this.artist,
    this.date,
    this.city,
  });

  final String id;
  final String name;
  final String? artist;
  final DateTime? date;
  final String? city;

  static SharedEvent? fromJson(Object? raw) {
    if (raw is! Map || raw['id'] is! String || raw['name'] is! String) {
      return null;
    }
    return SharedEvent(
      id: raw['id'] as String,
      name: raw['name'] as String,
      artist: raw['artist'] as String?,
      date: DateTime.tryParse('${raw['date']}'),
      city: raw['city'] as String?,
    );
  }
}

/// A person on the caller's Same Frequency list, with every signal the
/// server found (get_same_frequency). Nothing here is computed on the device
/// except the ranking.
class FrequencyCandidate {
  const FrequencyCandidate({
    required this.userId,
    required this.username,
    required this.compatibility,
    required this.affinity,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.sharedDiscoveries = const [],
    this.risingFamilies = const [],
    this.sharedEvents = 0,
    this.sharedEvent,
    this.timesShown = 0,
    this.lastShownAt,
    this.saved = false,
    this.sharedCommunities = const [],
  });

  /// Names of communities both belong to (smallest, most specific first).
  final List<String> sharedCommunities;

  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final int compatibility;
  final AffinityDetails affinity;

  /// Artists both recently started listening to.
  final List<String> sharedDiscoveries;

  /// Genre families both are moving toward (Musical DNA evolution).
  final List<String> risingFamilies;
  final int sharedEvents;
  final SharedEvent? sharedEvent;
  final int timesShown;
  final DateTime? lastShownAt;
  final bool saved;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;

  FrequencyCandidate copyWith({bool? saved, List<String>? sharedCommunities}) =>
      FrequencyCandidate(
        userId: userId,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
        bio: bio,
        compatibility: compatibility,
        affinity: affinity,
        sharedDiscoveries: sharedDiscoveries,
        risingFamilies: risingFamilies,
        sharedEvents: sharedEvents,
        sharedEvent: sharedEvent,
        timesShown: timesShown,
        lastShownAt: lastShownAt,
        saved: saved ?? this.saved,
        sharedCommunities: sharedCommunities ?? this.sharedCommunities,
      );

  static FrequencyCandidate? fromRow(Map<String, dynamic> row) {
    final id = row['user_id'];
    if (id is! String) return null;
    List<String> strings(Object? v) =>
        v is List ? v.whereType<String>().toList(growable: false) : const [];
    return FrequencyCandidate(
      userId: id,
      username: row['username']?.toString() ?? 'user',
      displayName: row['display_name'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      bio: row['bio'] as String?,
      compatibility: ((row['compatibility'] as num?) ?? 0).round().clamp(
        0,
        100,
      ),
      affinity: AffinityDetails.fromJson(row['details'], otherUserId: id),
      sharedDiscoveries: strings(row['shared_discoveries']),
      risingFamilies: strings(row['rising_families']),
      sharedEvents: ((row['shared_events'] as num?) ?? 0).toInt().clamp(
        0,
        1000,
      ),
      sharedEvent: SharedEvent.fromJson(row['shared_event']),
      timesShown: ((row['times_shown'] as num?) ?? 0).toInt(),
      lastShownAt: DateTime.tryParse('${row['last_shown_at']}'),
      saved: row['saved'] == true,
    );
  }
}
