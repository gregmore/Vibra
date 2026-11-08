# VIBRA music affinity engine

People ↔ people musical compatibility (algorithm version 2, 7 Nov 2026).
Replaces the earlier `0.55·√artists + 0.45·genres` formula. Person ↔ event
compatibility (`recommend-events`) is unchanged; see
`docs/spotify-integration.md` §4.

The goal: connect people through their **musical identity**, not only
identical artists. Two hip-hop fans who listen to different rappers should
match well; a hip-hop fan and a metal fan should not.

## 1. Genre taxonomy

Source of truth: `supabase/functions/_shared/genre_catalog.json`
(18 families, 157 subgenres, 385 aliases, a family relation matrix).
`python3 -I script/music/build_genre_catalog.py` generates
`_shared/genre_catalog.ts` (server) and `lib/core/music/genre_catalog.g.dart`
(app). A Flutter test fails if the Dart copy drifts from the JSON.

* **Families**: hip-hop, rnb, electronic, rock, metal, punk, pop, jazz, blues,
  reggae, latin, afro, country, folk, classical, soundtrack, gospel, world.
* **Subgenres**: each belongs to one family (`trap → hip-hop`,
  `alternative-rnb → rnb`, `deep-house → electronic`). Every family also has
  a generic entry with its own key (`hip-hop`, `rnb`…).
* **Relations**: weights between families that sound close (hip-hop–R&B 0.6,
  rock–punk 0.6, rock–metal 0.5, jazz–blues 0.55, …). Unrelated families
  have no relation (0).

### Normalisation (`classifyGenre`)

1. The label is lowercased and stripped of accents. `&` becomes "and", and
   separators (`-`, `/`, `_`, `.`) become spaces: "Hip-Hop/Rap" → "hip hop rap",
   "R&B" → "r and b".
2. An exact alias match wins ("k-pop", "kpop", "korean pop" → K-Pop).
3. Otherwise the **longest** alias contained as whole words wins:
   "italian trap" → Rap italiano, "dark trap" → Trap, "rap metal" → Nu Metal.
4. Unknown labels ("escape room") return nothing. They are never forced into
   a family.
5. The original Spotify label is kept in the result. Duplicates collapse,
   and each subgenre keeps its strongest weight.

Extending: add aliases or subgenres to the JSON, run the generator, and run
the tests. The catalogue test checks unique keys, valid families and
relations, and that every alias resolves to its own subgenre.

## 2. User musical profile

`buildGenreProfile` produces a subgenre vector with weights 0..1, where the
strongest genre = 1.

| Signal | Weight |
|---|---|
| Spotify top genres | Σ rank weights of the user's top artists carrying the genre (#1 = 1.00 … #50 = 0.51), normalised (`sync-music-profile/genres.ts`) |
| Picked genres | intensity / 100. In the UI: "Mi piace" 40, "Molto" 70, "Lo adoro" 100 |

When both sources exist, each subgenre keeps the stronger signal. Nothing is
inferred beyond these two sources. Spotify is optional: a user with picked
genres only is a complete participant.

Artist vector: Spotify ID (or normalised name) → rank weight.

## 3. Formula

Let `a`, `b` be the two subgenre vectors and `S` the similarity matrix:

```
S(i,i) = 1
S(i,j) = 0.8              same family, one side is the family's generic entry
S(i,j) = 0.6              same family, different subgenres (siblings)
S(i,j) = 0.6 × R(fi, fj)  different families, R = relation matrix
S(i,j) = 0                otherwise
```

**Genre compatibility**: soft cosine similarity (Sidorov et al., 2014)

```
G = aᵀ S b / √( aᵀ S a · bᵀ S b )        ∈ [0, 1]
```

* Identical subgenres contribute fully, sibling subgenres partially, and
  neighbouring families a little.
* Preference intensity counts: two Trap enthusiasts score higher than a Trap
  enthusiast and an occasional listener.
* Breadth is handled naturally: a very eclectic profile overlaps less
  intensely with a narrow one.

**Artist compatibility**:

```
A = √( Σ min(wa, wb) / Σ max(wa, wb) )   weighted Jaccard of rank weights
```

The `√` makes one strong shared artist visible without dominating.

**Final score**:

```
score = round(100 × (w_g · G + w_a · A))
w_g = 0.75, w_a = 0.25        (defaults)
```

* **Weights** are configurable with the Edge secret `AFFINITY_GENRE_WEIGHT`
  (0.7–1.0; the artist weight is 1 − it). Invalid values fall back to the
  defaults.
* **Missing artists:** if either side has no artists (picked genres only),
  the weights are redistributed: score = 100 × G.
* **Missing genres:** if either side has no classifiable genre, the result
  is `insufficient_data`. No number is produced or stored.
* **Symmetric** by construction: computeAffinity(A, B) = computeAffinity(B, A),
  covered by tests.
* **Reference values** (tests in `_shared/music_affinity.test.ts`):

  | Pair | Score |
  |---|---|
  | Identical profiles | 100 |
  | Travis Scott listener ↔ Kanye West listener (no shared artists) | 72 (high) |
  | Same listener ↔ Metallica listener | 0 |
  | Picked "Trap + Hip-Hop" ↔ Travis Scott listener | ≥ 80 |

  Because artists weigh only 25%, a pair that shares no artists tops out at
  75 ("high"). Shared artists are what lift a pair into "very high" or
  "exceptional".

## 4. Categories

| Score | Category |
|---|---|
| 90–100 | Exceptional musical affinity |
| 80–89 | Very high |
| 65–79 | High |
| 45–64 | Moderate |
| 25–44 | Different sounds |
| 0–24 | New musical worlds |

The two lower bands are worded as discovery, not incompatibility.

## 5. Explanations

The server stores reason codes, built only from the two profiles:

| Code | When |
|---|---|
| `shared_families` | families both sides weight ≥ 0.35 (up to 3) |
| `shared_subgenres` | specific subgenres both weight ≥ 0.25 (up to 3) |
| `different_subgenres` | same main family, but each side's favourite subgenre in it differs |
| `related_families` | the two top families differ but are related (R ≥ 0.3) |
| `shared_artists` | count and up to 3 names of artists both have |
| `discovery` | no shared family and score < 45 |
| `diversity` | `both_eclectic` (both ≥ 65), `both_focused` (both < 35 and a shared family) or `contrast` (diversity differs by ≥ 40). Same diversity measure as the Musical DNA (`docs/musical-dna.md` §2) |
| `common_ground` | fallback: families both listen to at any weight, when no other reason applies |

**Every scored pair has at least one reason other than `diversity`.** If no
rule above fires, the engine adds `common_ground`. With nothing in common
it uses the closest `related_families` pair, and otherwise `discovery`.
A property test over 400 random profile pairs checks this. The same test
checks symmetry and the 0–100 range, and that every named family and artist
appears on both sides.

### Weight calibration

`music_affinity.test.ts` ("calibration") sweeps the genre weight over the
accepted range. Two invariants must hold:

* listeners of the same genres with different artists (Travis Scott ↔
  Kanye West) score "high" (≥ 65);
* they outrank listeners with the same artists but unrelated genres.

Measured scores for the Travis ↔ Kanye pair: 0.65 → 62, 0.70 → 67,
0.75 → 72, 0.80 → 77. Same artists with unrelated genres: 0.70 → 45,
0.75 → 41. The default 0.75 is the smallest round value where the first
pair is "high" and the second stays below "moderate". Below 0.70 the first
invariant breaks, which is why the configurable range starts there.

The app turns each code into a sentence with l10n (5 languages, IT/EN
included) in `lib/presentation/localization/music_affinity_text.dart`. It
skips unknown codes and never adds its own reasons.

## 6. Storage, cache and invalidation

* **`user_matches`** (pair `a < b`, written by the service role only) gains
  two columns: `details` jsonb (bands, shared lists, top families per user,
  reasons, weights) and `algorithm_version`. No tokens, play history or
  Spotify IDs are stored in `details`.
* **Recompute triggers** (`recomputeMatches`, `_shared/music_sync.ts`):
  * a Spotify sync (first, manual, hourly worker every 24 h);
  * `calculate-match` after the user saves picked genres;
  * another user's recompute, because pairs are symmetric and shared.
* **`save_affinity_matches`** writes all eligible pairs with score > 0 in one
  transaction, holding the same user row lock as disconnect and sync. It also
  deletes this user's cached pairs that are no longer supported:
  * pairs whose candidate was considered but now scores 0 or has
    insufficient data;
  * when the candidate list was not truncated, every pair that is no longer
    eligible.
* **Removing all picked genres:** a genre-only user who removes every genre
  loses their cached pairs at once (trigger).
* **Spotify disconnect / account deletion:** the existing behaviour is
  unchanged. The personal data export now also includes picked genres and
  ignored profiles.
* **Notifications:** only new pairs with score ≥ 80 trigger a push. Every
  eligible pair is now cached, so a push per row would be noise.

## 7. Discovery feed

`get_affinity_feed(limit, offset)` is SECURITY INVOKER. The existing RLS
keeps applying:
* mutual consent and blocks (`user_matches` policies);
* test-segment isolation (`users_public`).

It additionally excludes:
* ignored profiles (`affinity_dismissals`, written by "Ignora");
* people already connected (accepted or pending friendship, either
  direction).

Order: score, then profile completeness (photo and bio), then most recently
updated.

The app (`diversifyAffinityFeed`) keeps the ranking but gives every 5th slot
to the best **related-but-different** profile in the moderate band. This
means the deck is not only clones of the user's own taste. Nobody is added
or dropped.

Consent: the existing `privacy_preferences.spotify_matching` flag, now
labelled "Affinità musicale", covers both Spotify data and picked genres.
The genre screen has its own explicit switch ("Mostrami alle persone con
gusti affini").

## 8. App

* **Affinity deck** (`/vibra-match`):
  * gauge and percentage, plus the category chip;
  * a short quote, shared genres (or the other person's main genres) and
    artists in common;
  * "Perché siete affini" reasons;
  * Invia Vibra / Ignora.
* **Genre picker** (`/music-genres`, from Settings → Musica and the Social
  card):
  * chips grouped by family, plus search;
  * tap a picked chip to change its intensity, × to remove it;
  * up to 30 genres; optional, never required.
* **User profile:** shows the cached pair score and details when RLS allows
  it.

## 9. Edge cases

| Case | Behaviour |
|---|---|
| No Spotify | Picked genres → genre-only score; otherwise no score |
| Expired/revoked Spotify | Existing revocation flow deletes Spotify data; picked genres remain |
| No top artists / no genres | Artists missing → weights redistributed; genres missing → insufficient data |
| One genre only | Valid; scores against anyone sharing or near that genre |
| Very eclectic taste | Soft cosine lowers intensity per genre; no inflation |
| Completely different genres | 0–24, "discovery" reason |
| Identical artists | Artist part = 1; genre part decides the rest |
| Disconnect Spotify | Existing behaviour: pairs and consent cleared; re-enable from the genre screen |
| Changed taste | Recompute replaces and invalidates pairs atomically |
| New user | No data → no pairs, Social shows "Collega" / "scegli i tuoi generi" |
| Deleted / blocked | FK cascades; blocked pairs hidden by RLS and never recomputed |

## 10. Tests

* **Deno** (`_shared/music_affinity.test.ts`):
  * catalogue integrity and normalisation;
  * brief scenarios 1–8, symmetry and intensity;
  * explanations, configurable weights and bands;
  * pipeline atomicity and a no-secrets check on `details`.
* **pgTAP** (`supabase/tests/database/15_music_affinity_test.sql`):
  * candidates (blocked, opt-out, test segment) and service-role-only writes;
  * stale-pair invalidation and the feed (blocked, ignored, connected);
  * owner-only genres and dismissals, and key validation.
* **Flutter**:
  * `test/unit/music_affinity_test.dart`: catalogue sync, parsing, bands,
    reasons in IT/EN, diversity;
  * `test/presentation/screens/music_genres_screen_test.dart`;
  * `send_vibra_test.dart`: card explanation, persistent ignore.

## 11. Known limitations

* **Spotify genre data:** genres per artist come from Spotify, which no
  longer returns genres for some artists to new apps. The fewer genres, the
  more the score leans on picked genres.
* **Relation weights** are hand-tuned, not learned from listening data.
  They live in one JSON file so they can be tuned.
* **Artist similarity** is exact (same artist). "Similar artists" are
  captured through their genres, because Spotify's related-artists endpoint
  is not available to new apps.
* **Candidate cap:** each recompute scores up to 500 candidates (most
  recently active first). Pairs beyond that are refreshed by the other
  user's own recompute.
* **Spotify flag:** affinity (with or without Spotify) sits behind the
  existing Spotify kill-switch (`launch_features.spotify` and the
  `SPOTIFY_ENABLED` secret).
