import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/taste_evolution.dart';

Map<String, dynamic> snap(
  String day,
  Map<String, int> families,
  Map<String, int> subgenres,
  List<String> artists,
) => {
  'captured_on': day,
  'dna': {
    'families': [
      for (final e in families.entries)
        {'key': e.key, 'percent': e.value, 'share': e.value / 100},
    ],
    'subgenres': [
      for (final e in subgenres.entries)
        {
          'key': e.key,
          'family': 'x',
          'percent': e.value,
          'share': e.value / 100,
        },
    ],
    'artists': [
      for (final a in artists) {'key': a, 'name': a},
    ],
  },
};

void main() {
  final evolution = TasteEvolution.fromJson({
    'tracking': true,
    'days': 90,
    'snapshot_count': 120,
    'oldest_on': '2026-07-01',
    'current': snap(
      '2026-11-08',
      {'hip-hop': 50, 'electronic': 30, 'rnb': 20},
      {'trap': 30, 'techno': 20, 'neo-soul': 10, 'drill': 2},
      ['Fred again..', 'Travis Scott', 'A', 'B', 'C', 'D', 'E', 'F', 'Burial'],
    ),
    'baseline': {
      ...snap(
        '2026-08-08',
        {'hip-hop': 60, 'rock': 30, 'rnb': 10},
        {'trap': 40, 'indie-rock': 25},
        [
          'Travis Scott',
          'Arctic Monkeys',
          'A',
          'B',
          'C',
          'D',
          'E',
          'F',
          'G',
          'H',
          'I',
          'J',
          'K',
          'L',
          'Burial',
        ],
      ),
      'full_period': true,
    },
    'timeline': [
      {
        'captured_on': '2026-08-08',
        'families': [
          {'key': 'hip-hop', 'percent': 60},
        ],
      },
      {
        'captured_on': '2026-11-08',
        'families': [
          {'key': 'hip-hop', 'percent': 50},
        ],
      },
    ],
    'communities': [
      {
        'id': 'c1',
        'name': 'Techno Underground',
        'genre_family': 'electronic',
        'joined_at': '2026-10-01T10:00:00Z',
      },
    ],
  });

  test('new genres are subgenres absent before (noise ignored)', () {
    expect(evolution.newGenres.map((s) => s.key), ['techno', 'neo-soul']);
  });

  test('emerging artists are new to the top 10 or rose 5+ places', () {
    final names = {for (final a in evolution.emergingArtists) a.name: a};
    expect(names['Fred again..']!.isNew, isTrue);
    expect(names['Burial']!.previousRank, 15);
    expect(names.containsKey('Travis Scott'), isFalse);
  });

  test('distribution compares then and now; previous tastes are listed', () {
    final rock = evolution.distribution.firstWhere((f) => f.key == 'rock');
    expect((rock.before, rock.now), (30, 0));
    expect(evolution.previousGenres.map((f) => f.key), ['rock']);
    expect(evolution.previousArtists, ['Arctic Monkeys']);
    // |−10| + |+30| + |+10| + |−30| = 80 → 40 points of change.
    expect(evolution.changePoints, 40);
    expect(evolution.evolved, isTrue);
  });

  test('real timeline and communities; no comparison without a baseline', () {
    expect(evolution.timeline.length, 2);
    expect(evolution.communities.single.name, 'Techno Underground');
    final empty = TasteEvolution.fromJson({
      'tracking': true,
      'snapshot_count': 1,
      'current': snap('2026-11-08', {'pop': 100}, {}, []),
      'baseline': null,
    });
    expect(empty.canCompare, isFalse);
    expect(empty.newGenres, isEmpty);
    expect(empty.emergingArtists, isEmpty);
    expect(empty.changePoints, 0);
  });
}
