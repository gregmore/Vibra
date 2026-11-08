import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/musical_dna.dart';

Map<String, Object?> _snapshot(Map<String, int> families) => {
  'version': 1,
  'families': [
    for (final e in families.entries)
      {'key': e.key, 'share': e.value / 100, 'percent': e.value, 'artists': []},
  ],
  'subgenres': const [],
  'diversity': {'score': 40, 'tier': 'balanced', 'families': 2, 'subgenres': 2},
  'sources': {
    'spotify': true,
    'manual': false,
    'artists': 50,
    'artists_classified': 44,
  },
};

void main() {
  test('parses a stored snapshot and skips malformed entries', () {
    final dna = MusicalDna.fromJson({
      'families': [
        {
          'key': 'hip-hop',
          'share': 0.62,
          'percent': 62,
          'artists': ['Travis Scott', 3],
        },
        {'key': 'rnb', 'share': 0.38, 'percent': 38},
        {'share': 0.1},
        'junk',
      ],
      'subgenres': [
        {'key': 'trap', 'family': 'hip-hop', 'share': 0.4, 'percent': 40},
        {'key': 'no-family'},
      ],
      'diversity': {'score': 47, 'tier': 'balanced'},
      'sources': {
        'spotify': true,
        'manual': true,
        'artists': 50,
        'artists_classified': 41,
        'tracks': 50,
        'manual_genres': 3,
      },
    })!;
    expect(dna.families.map((f) => f.key), ['hip-hop', 'rnb']);
    expect(dna.families.first.artists, ['Travis Scott']);
    expect(dna.subgenres.single.key, 'trap');
    expect(dna.subgenresOf('hip-hop').single.percent, 40);
    expect(dna.diversityScore, 47);
    expect(dna.diversityTier, DnaDiversityTier.balanced);
    expect(dna.sources.artistsClassified, 41);
    expect(dna.sources.manualGenres, 3);
  });

  test('no families means no DNA', () {
    expect(MusicalDna.fromJson(null), isNull);
    expect(MusicalDna.fromJson({'families': []}), isNull);
    expect(MusicalDna.fromJson({'families': 'x'}), isNull);
  });

  test('unknown visibility and tier values fall back safely', () {
    expect(DnaVisibility.fromName('public'), DnaVisibility.public);
    expect(DnaVisibility.fromName('matches'), DnaVisibility.matches);
    expect(DnaVisibility.fromName('everyone'), DnaVisibility.private);
    expect(DnaVisibility.fromName(null), DnaVisibility.private);
    expect(DnaDiversityTier.fromName('wild'), DnaDiversityTier.focused);
  });

  test('shifts list families that moved, biggest first', () {
    final older = MusicalDna.fromJson(
      _snapshot({'hip-hop': 60, 'rnb': 38, 'jazz': 2}),
    )!;
    final newer = MusicalDna.fromJson(
      _snapshot({'hip-hop': 50, 'rnb': 36, 'electronic': 14}),
    )!;
    final shifts = dnaShifts(older, newer);
    expect(shifts.map((s) => (s.family, s.delta)), [
      ('electronic', 14),
      ('hip-hop', -10),
    ]);
    expect(dnaShifts(older, older), isEmpty);
  });

  test('history sampling keeps oldest and newest, oldest first', () {
    final newestFirst = [
      for (var i = 9; i >= 0; i--)
        MusicalDna.fromJson(
          _snapshot({'hip-hop': 100}),
          capturedOn: DateTime(2026, 1, 1 + i),
        )!,
    ];
    final sample = sampleDnaHistory(newestFirst, count: 4);
    expect(sample.length, 4);
    expect(sample.first.capturedOn, DateTime(2026, 1, 1));
    expect(sample.last.capturedOn, DateTime(2026, 1, 10));
    expect(
      sampleDnaHistory(newestFirst.take(2).toList()).map((d) => d.capturedOn),
      [DateTime(2026, 1, 9), DateTime(2026, 1, 10)],
    );
  });
}
