import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/core/music/genre_catalog.dart';
import 'package:vibra/domain/entities/music_affinity.dart';
import 'package:vibra/l10n/app_localizations_en.dart';
import 'package:vibra/l10n/app_localizations_it.dart';
import 'package:vibra/presentation/localization/music_affinity_text.dart';

void main() {
  test('Dart catalogue is generated from the server JSON (no drift)', () {
    final json =
        jsonDecode(
              File(
                'supabase/functions/_shared/genre_catalog.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(GenreCatalog.version, json['version']);
    expect(
      GenreCatalog.families.map((f) => f.key),
      (json['families'] as List).map((f) => f['key']),
    );
    expect(
      GenreCatalog.subgenres.map((s) => '${s.family}/${s.key}/${s.label}'),
      (json['subgenres'] as List).map(
        (s) => '${s['family']}/${s['key']}/${s['label']}',
      ),
    );
    // Every family has its generic entry and a localized label.
    final it = AppLocalizationsIt();
    for (final family in GenreCatalog.families) {
      expect(GenreCatalog.subgenre(family.key)?.isGeneric, isTrue);
      expect(genreFamilyLabel(it, family.key), isNot(family.key));
    }
  });

  test('catalogue search ignores case and accents and matches families', () {
    final it = AppLocalizationsIt();
    expect(GenreCatalog.search('TRAP').map((s) => s.key), contains('trap'));
    expect(GenreCatalog.search('neo soul').single.key, 'neo-soul');
    final electronic = GenreCatalog.search(
      'elettronica',
      familyLabel: (key) => genreFamilyLabel(it, key),
    );
    expect(electronic.map((s) => s.key), containsAll(['house', 'techno']));
    expect(GenreCatalog.search('   '), isEmpty);
  });

  test('categories follow the documented bands', () {
    expect(
      [
        100,
        90,
        89,
        80,
        79,
        65,
        64,
        45,
        44,
        25,
        24,
        0,
      ].map(AffinityCategory.fromScore),
      [
        AffinityCategory.exceptional,
        AffinityCategory.exceptional,
        AffinityCategory.veryHigh,
        AffinityCategory.veryHigh,
        AffinityCategory.high,
        AffinityCategory.high,
        AffinityCategory.moderate,
        AffinityCategory.moderate,
        AffinityCategory.low,
        AffinityCategory.low,
        AffinityCategory.veryLow,
        AffinityCategory.veryLow,
      ],
    );
  });

  test('details parse the server explanation and skip anything unknown', () {
    final details = AffinityDetails.fromJson({
      'v': 2,
      'genre': 0.95,
      'artist': null,
      'shared_families': ['hip-hop', 'rnb'],
      'shared_subgenres': ['trap'],
      'shared_artists': ['Future', 'Metro Boomin'],
      'shared_artist_count': 2,
      'top_families': {
        'other': ['hip-hop', 'rnb'],
        'me': ['hip-hop'],
      },
      'reasons': [
        {
          'code': 'shared_families',
          'families': ['hip-hop', 'rnb'],
        },
        {'code': 'from_a_future_engine'},
        {
          'code': 'shared_artists',
          'count': 2,
          'artists': ['Future'],
        },
        'garbage',
        {'code': 'related_families', 'families': 'not-a-list'},
      ],
    }, otherUserId: 'other');
    expect(details.reasons, hasLength(2));
    expect(details.theirTopFamilies, ['hip-hop', 'rnb']);
    expect(details.genreScore, .95);
    expect(details.artistScore, isNull);
    expect(AffinityDetails.fromJson(null, otherUserId: 'x').reasons, isEmpty);
    expect(AffinityDetails.fromJson('x', otherUserId: 'x').sharedArtists, []);
  });

  test('reasons become Italian and English sentences from data only', () {
    final it = AppLocalizationsIt();
    final en = AppLocalizationsEn();
    const shared = SharedFamiliesReason(['hip-hop', 'electronic']);
    expect(
      affinityReasonText(it, shared),
      'Entrambi ascoltate soprattutto Hip-Hop e Elettronica.',
    );
    expect(
      affinityReasonText(en, shared),
      'You both mostly listen to Hip-Hop and Electronic.',
    );
    expect(
      affinityReasonText(it, const SharedSubgenresReason(['trap', 'hip-hop'])),
      'Condividete la passione per Trap e Hip-Hop.',
    );
    expect(
      affinityReasonText(it, const SharedArtistsReason(3, [])),
      'Condividete 3 artisti preferiti.',
    );
    expect(
      affinityReasonText(it, const DifferentSubgenresReason('electronic')),
      'Amate entrambi il genere Elettronica, ma preferite sottogeneri diversi.',
    );
    expect(
      affinityReasonText(en, const RelatedFamiliesReason('hip-hop', 'rnb')),
      'Hip-Hop and R&B are neighbouring sounds.',
    );
  });

  test('diversity: every 5th slot is a related-but-different profile', () {
    AffinityDetails related() => const AffinityDetails(
      sharedFamilies: [],
      sharedSubgenres: [],
      sharedArtists: [],
      sharedArtistCount: 0,
      theirTopFamilies: [],
      reasons: [RelatedFamiliesReason('hip-hop', 'rnb')],
    );
    final ranked = <(String, int, AffinityDetails?)>[
      ('a', 95, null),
      ('b', 92, null),
      ('c', 90, null),
      ('d', 88, null),
      ('e', 86, null),
      ('f', 84, null),
      ('g', 55, related()),
      ('h', 50, null),
    ];
    final out = diversifyAffinityFeed(
      ranked,
      score: (x) => x.$2,
      details: (x) => x.$3,
    );
    expect(out.map((x) => x.$1), ['a', 'b', 'c', 'd', 'g', 'e', 'f', 'h']);
    // Nobody is added or dropped, and it is deterministic.
    expect(out.toSet(), ranked.toSet());
    expect(
      diversifyAffinityFeed(ranked, score: (x) => x.$2, details: (x) => x.$3),
      out,
    );
    // Without a discovery candidate the ranking is untouched.
    final plain = ranked.where((x) => x.$1 != 'g').toList();
    expect(
      diversifyAffinityFeed(plain, score: (x) => x.$2, details: (x) => x.$3),
      plain,
    );
  });

  test('common ground and diversity reasons parse and read from data', () {
    final details = AffinityDetails.fromJson({
      'reasons': [
        {
          'code': 'common_ground',
          'families': ['jazz', 'rock'],
        },
        {'code': 'diversity', 'pattern': 'both_eclectic'},
        {'code': 'diversity', 'pattern': 'something_new'},
        {'code': 'common_ground', 'families': []},
      ],
    }, otherUserId: 'u2');
    expect(details.reasons.length, 2);
    final en = AppLocalizationsEn();
    expect(
      affinityReasonText(en, details.reasons[0]),
      'You both listen to Jazz and Rock, in different amounts.',
    );
    expect(
      affinityReasonText(en, details.reasons[1]),
      "You're both eclectic listeners, moving across very different genres.",
    );
    expect(en.affinityHeadlineSentence(89), 'You have 89% musical affinity.');
    expect(
      AppLocalizationsIt().affinityHeadlineSentence(89),
      "Tra voi c'è un'affinità musicale: 89%.",
    );
  });
}
