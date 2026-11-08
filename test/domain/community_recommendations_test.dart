import 'package:flutter_test/flutter_test.dart';
import 'package:vibra/domain/entities/community.dart';
import 'package:vibra/domain/entities/musical_dna.dart';
import 'package:vibra/domain/usecases/community_recommendations.dart';

Community _genre(
  String id,
  String key,
  String family, {
  int members = 0,
  bool joined = false,
}) => Community(
  id: id,
  slug: id,
  name: id,
  kind: CommunityKind.genre,
  genreKey: key,
  genreFamily: family,
  memberCount: members,
  myRole: joined ? CommunityRole.member : null,
);

Community _artist(String id, String artist) => Community(
  id: id,
  slug: id,
  name: '$artist Fans',
  kind: CommunityKind.artist,
  artistName: artist,
);

final _dna = MusicalDna.fromJson({
  'families': [
    {'key': 'hip-hop', 'share': 0.62, 'percent': 62},
    {'key': 'rnb', 'share': 0.30, 'percent': 30},
    {'key': 'metal', 'share': 0.08, 'percent': 8},
  ],
  'subgenres': [
    {'key': 'trap', 'family': 'hip-hop', 'share': 0.40, 'percent': 40},
    {
      'key': 'underground-hip-hop',
      'family': 'hip-hop',
      'share': 0.12,
      'percent': 12,
    },
    {'key': 'alternative-rnb', 'family': 'rnb', 'share': 0.20, 'percent': 20},
    {'key': 'jazz', 'family': 'jazz', 'share': 0.02, 'percent': 2},
  ],
  'artists': [
    {'key': 'id:1', 'name': 'Travis Scott'},
    {'key': 'id:2', 'name': 'Playboi Carti'},
    {'key': 'id:3', 'name': 'SZA'},
  ],
})!;

void main() {
  test('recommends from real DNA data, with the data point as the reason', () {
    final recs = recommendCommunities([
      _genre('trap', 'trap', 'hip-hop'),
      _genre('hh', 'hip-hop', 'hip-hop'),
      _genre('alt-rnb', 'alternative-rnb', 'rnb'),
      _genre('jazz', 'jazz', 'jazz'),
      _genre('techno', 'techno', 'electronic'),
      _artist('travis', 'Travis Scott'),
      _artist('drake', 'Drake'),
    ], _dna);
    final ids = recs.map((r) => r.community.id).toList();
    expect(ids.first, 'travis');
    expect(ids, containsAll(['trap', 'hh', 'alt-rnb']));
    // Not in the DNA (or below 8%): never suggested.
    expect(ids, isNot(contains('jazz')));
    expect(ids, isNot(contains('techno')));
    expect(ids, isNot(contains('drake')));
    final trap = recs.firstWhere((r) => r.community.id == 'trap').reason;
    expect(trap, isA<GenreShareReason>());
    expect((trap as GenreShareReason).percent, 40);
    final travis = recs.first.reason as TopArtistReason;
    expect(travis.artist, 'Travis Scott');
  });

  test('joined communities are skipped; one family cannot fill the list', () {
    final recs = recommendCommunities([
      _genre('trap', 'trap', 'hip-hop', joined: true),
      _genre('hh', 'hip-hop', 'hip-hop'),
      _genre('ug', 'underground-hip-hop', 'hip-hop'),
      _genre('hh2', 'hip-hop', 'hip-hop', members: 10),
      _genre('rnb', 'rnb', 'rnb'),
    ], _dna);
    final ids = recs.map((r) => r.community.id).toList();
    expect(ids, isNot(contains('trap')));
    expect(ids.where((id) => id.startsWith('h') || id == 'ug').length, 2);
    expect(ids, contains('rnb'));
  });

  test('no DNA, no recommendations', () {
    expect(
      recommendCommunities([_genre('hh', 'hip-hop', 'hip-hop')], null),
      isEmpty,
    );
  });

  test('top artists without a community become "start one" suggestions', () {
    expect(artistsWithoutCommunity([_artist('travis', 'travis scott')], _dna), [
      'Playboi Carti',
      'SZA',
    ]);
  });
}
