import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_affinity.dart';
import 'package:vibra/domain/entities/same_frequency.dart';
import 'package:vibra/domain/usecases/same_frequency.dart';

final _now = DateTime.utc(2026, 11, 9, 12);

FrequencyCandidate _c(
  String id,
  int score, {
  String family = 'hip-hop',
  int sharedArtists = 0,
  List<String> discoveries = const [],
  List<String> rising = const [],
  int events = 0,
  int timesShown = 0,
  DateTime? lastShownAt,
  bool saved = false,
}) => FrequencyCandidate(
  userId: id,
  username: id,
  compatibility: score,
  affinity: AffinityDetails.fromJson({
    'shared_artist_count': sharedArtists,
    'shared_artists': [for (var i = 0; i < sharedArtists; i++) 'A$i'],
    'top_families': {
      id: [family],
    },
  }, otherUserId: id),
  sharedDiscoveries: discoveries,
  risingFamilies: rising,
  sharedEvents: events,
  timesShown: timesShown,
  lastShownAt: lastShownAt,
  saved: saved,
);

List<String> _ids(FrequencyResult r) => [for (final p in r.people) p.userId];

void main() {
  test('strong connection: high affinity, or moderate with a real signal', () {
    expect(isStrongConnection(_c('a', 65)), isTrue);
    expect(isStrongConnection(_c('b', 60)), isFalse);
    expect(isStrongConnection(_c('c', 50, sharedArtists: 1)), isTrue);
    expect(isStrongConnection(_c('d', 50, events: 1)), isTrue);
    expect(isStrongConnection(_c('e', 44, sharedArtists: 3)), isFalse);
  });

  test(
    'not a sort by percentage: concrete signals can outrank a higher score',
    () {
      final r = rankSameFrequency([
        _c('plain', 78),
        _c(
          'rich',
          70,
          sharedArtists: 4,
          discoveries: ['X', 'Y'],
          rising: ['electronic'],
        ),
      ], now: _now);
      expect(_ids(r), ['rich', 'plain']);
      expect(r.strongCount, 2);
    },
  );

  test('rotation: recently and often shown people step back; saved stay', () {
    final fresh = _c('fresh', 80);
    final seenToday = _c(
      'today',
      82,
      lastShownAt: _now.subtract(const Duration(hours: 3)),
    );
    final seenOften = _c(
      'often',
      82,
      family: 'rnb',
      timesShown: 6,
      lastShownAt: _now.subtract(const Duration(days: 5)),
    );
    expect(
      _ids(rankSameFrequency([seenToday, fresh, seenOften], now: _now)).first,
      'fresh',
    );

    final saved = _c(
      'saved',
      82,
      saved: true,
      timesShown: 9,
      lastShownAt: _now,
    );
    expect(rotationFactor(saved, _now), 1);
    expect(
      rotationFactor(seenToday, _now),
      lessThan(rotationFactor(fresh, _now)),
    );
  });

  test('a person shown repeatedly eventually yields their slot', () {
    final regular = _c('regular', 80, family: 'rnb');
    final candidates = [
      for (var i = 0; i < 12; i++) _c('p$i', 74, family: 'f$i'),
      regular,
    ];
    expect(_ids(rankSameFrequency(candidates, now: _now)).first, 'regular');
    final afterManyViews = _c(
      'regular',
      80,
      family: 'rnb',
      timesShown: 8,
      lastShownAt: _now.subtract(const Duration(hours: 2)),
    );
    final ranked = _ids(
      rankSameFrequency([...candidates.take(12), afterManyViews], now: _now),
    );
    expect(ranked, isNot(contains('regular')));
  });

  test('diversity: the same main family does not fill the top of the list', () {
    final candidates = [
      _c('h1', 90),
      _c('h2', 89),
      _c('h3', 88),
      _c('e1', 84, family: 'electronic'),
      _c('j1', 83, family: 'jazz'),
    ];
    final ranked = _ids(rankSameFrequency(candidates, now: _now));
    expect(ranked.take(3).toSet(), {'h1', 'e1', 'j1'});
    expect(ranked.toSet(), candidates.map((c) => c.userId).toSet());
  });

  test(
    'limit caps the list but the headline counts every strong connection',
    () {
      final candidates = [for (var i = 0; i < 20; i++) _c('p$i', 70 + (i % 5))];
      final r = rankSameFrequency(candidates, now: _now, limit: 7);
      expect(r.people.length, 7);
      expect(r.strongCount, 20);
    },
  );

  test('deterministic for the same input and time', () {
    final candidates = [_c('a', 70), _c('b', 70), _c('c', 70, family: 'rnb')];
    expect(
      _ids(rankSameFrequency(candidates, now: _now)),
      _ids(rankSameFrequency(candidates.reversed.toList(), now: _now)),
    );
  });

  test('server rows parse; missing signals default to none', () {
    final c = FrequencyCandidate.fromRow({
      'user_id': 'u1',
      'username': 'alex',
      'compatibility': 81.6,
      'details': {
        'shared_artist_count': 2,
        'shared_artists': ['Future', 'SZA'],
      },
      'shared_discoveries': ['Fred again..', 4],
      'rising_families': ['electronic'],
      'shared_events': 1,
      'shared_event': {
        'id': 'e1',
        'name': 'Travis Scott',
        'date': '2026-12-12T20:00:00Z',
      },
      'times_shown': 2,
      'saved': true,
    })!;
    expect(c.compatibility, 82);
    expect(c.sharedDiscoveries, ['Fred again..']);
    expect(c.sharedEvent?.name, 'Travis Scott');
    expect(c.saved, isTrue);
    final bare = FrequencyCandidate.fromRow({'user_id': 'u2'})!;
    expect(bare.sharedEvents, 0);
    expect(bare.sharedEvent, isNull);
    expect(FrequencyCandidate.fromRow({'username': 'x'}), isNull);
  });
}
