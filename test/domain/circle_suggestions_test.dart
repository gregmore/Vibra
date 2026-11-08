import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/music_affinity.dart';
import 'package:vibra/domain/entities/musical_dna.dart';
import 'package:vibra/domain/entities/same_frequency.dart';
import 'package:vibra/domain/usecases/circle_suggestions.dart';

FrequencyCandidate _c(
  String id,
  int score, {
  List<String> families = const ['hip-hop'],
  List<String> subgenres = const [],
  List<String> artists = const [],
}) => FrequencyCandidate(
  userId: id,
  username: id,
  compatibility: score,
  affinity: AffinityDetails.fromJson({
    'shared_families': families,
    'shared_subgenres': subgenres,
    'shared_artists': artists,
    'shared_artist_count': artists.length,
  }, otherUserId: id),
);

final _dna = MusicalDna.fromJson({
  'families': [
    {'key': 'hip-hop', 'share': 0.7, 'percent': 70},
    {'key': 'electronic', 'share': 0.3, 'percent': 30},
  ],
  'subgenres': [
    {'key': 'trap', 'family': 'hip-hop', 'share': 0.4, 'percent': 40},
  ],
})!;

void main() {
  test('groups compatible people by a shared artist, subgenre or family', () {
    final s = suggestCircles([
      _c('a', 90, subgenres: ['trap'], artists: ['Travis Scott']),
      _c('b', 85, subgenres: ['trap'], artists: ['Travis Scott']),
      _c('c', 80, subgenres: ['trap']),
      _c('d', 75, families: ['electronic']),
      _c('e', 70, families: ['electronic']),
    ], _dna);
    expect(s.first.basis, SuggestionBasis.artist);
    expect(s.first.key, 'Travis Scott');
    expect(s.first.people.map((p) => p.userId), ['a', 'b']);
    final trap = s.firstWhere((x) => x.key == 'trap');
    expect(trap.people.map((p) => p.userId), containsAll(['c']));
    expect(s.any((x) => x.key == 'electronic'), isTrue);
  });

  test('only strong matches; never fewer than two people; capped size', () {
    expect(suggestCircles([_c('a', 90), _c('b', 50)], _dna), isEmpty);
    final many = suggestCircles(
      [for (var i = 0; i < 10; i++) _c('p$i', 70 + i)],
      _dna,
      peoplePerCircle: 4,
    );
    expect(many.every((s) => s.people.length <= 4), isTrue);
  });

  test('one person is proposed in at most two circles', () {
    final s = suggestCircles(
      [
        _c(
          'a',
          95,
          subgenres: ['trap'],
          families: ['hip-hop', 'electronic'],
          artists: ['X'],
        ),
        _c(
          'b',
          90,
          subgenres: ['trap'],
          families: ['hip-hop', 'electronic'],
          artists: ['X'],
        ),
        _c('c', 85, families: ['hip-hop', 'electronic']),
      ],
      _dna,
      maxSuggestions: 5,
    );
    final countA = s.where((x) => x.people.any((p) => p.userId == 'a')).length;
    expect(countA, lessThanOrEqualTo(2));
  });
}
