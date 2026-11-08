# VIBRA Musical DNA

Each user's musical identity as a genre distribution that adds up to 100%
(version 1, Nov 2026). Engine: `supabase/functions/_shared/musical_dna.ts`.
Storage and access: migration `20261108000000_musical_dna.sql`. App: `/musical-dna`.

It reuses the affinity engine's genre catalogue and classifier
(`docs/music-affinity-engine.md` §1). Detection, normalisation and subgenre
classification are therefore identical across matching and DNA.

## 1. Inputs (only the user's own data)

| Source | Used as |
|---|---|
| Spotify top 50 artists (≈ 6 months) | rank weight 1.00 (#1) … 0.51 (#50) |
| Each artist's Spotify genres | classified to family → subgenre; unknown labels skipped |
| Spotify top 50 tracks | each slot adds 0.5 × its rank weight to the artist who made it |
| Picked genres (`user_genre_preferences`) | intensity / 100 |

**Recently played** stores only timestamps, which feed the listening
heatmap. It carries no track or artist, so it does not affect genres.

Profiles synced before this release have no per-artist genres. For those,
the DNA uses the aggregated `top_genres`, which are already rank-weighted,
until the next daily sync (`sources.spotify_basis = "genres"`).

## 2. Computation

1. **Artist split.** An artist's weight is split equally across its distinct
   subgenres. An artist tagged with five genres therefore counts once, not
   five times.
2. **Spotify distribution.** The subgenre masses are normalised to sum to 1.
3. **Picked distribution.** The picked genres are normalised to sum to 1.
4. **Blend.** With both sources, the DNA is 70% Spotify and 30% picked
   genres (`MANUAL_SHARE`). With only one source, it is 100% that source.
   With neither, there is no DNA. Nothing is invented.
5. **Families.** Each family is the sum of its subgenres.
6. **Rounding.** Families and subgenres are rounded with the largest
   remainder method, so the shown percentages always add up to exactly 100.
7. **Artists per family.** The top 3 artists by contribution are named in
   each family ("Through Travis Scott, Kanye West").
8. **Diversity** (0–100): `100 × (0.7·GS(families) + 0.3·GS(subgenres))`,
   where GS is the Gini–Simpson index (1 − Σp²). Tiers: < 35 focused,
   < 65 balanced, ≥ 65 eclectic. Spreading across different families counts
   more than spreading across subgenres of one family.

Covered by `_shared/musical_dna.test.ts`.

## 3. Storage and history

* **`musical_dna_snapshots`**: one row per user per day. The newest row is
  the current DNA; older rows make up the evolution view.
  * Rows older than 400 days are trimmed on each write.
  * RLS lets only the owner select their rows; only the service role writes.
* **When it is recomputed:**
  * every full Spotify sync (first connect, manual sync, daily worker);
  * `calculate-match`, which the app calls after saving picked genres and
    the first time the DNA screen finds no snapshot.
* **When it is removed:**
  * if the user ends up with no musical data, every snapshot is deleted;
  * Spotify disconnect or revocation deletes the music profile, and a
    trigger deletes the snapshots with it. A user who still has picked
    genres gets a genre-only DNA on the next `calculate-match`;
  * account deletion cascades.
* The personal data export includes `musical_dna`.

## 4. Visibility

`privacy_preferences.musical_dna_visibility` is `private` by default.

| Setting | Who else can read it (`get_musical_dna`) |
|---|---|
| `public` | any signed-in user |
| `matches` | users with a cached affinity pair (both consented to musical matching) or an accepted connection |
| `private` | nobody |

The owner always sees their own DNA. Blocks (in either direction) and
different test segments always hide it. The DNA still feeds the user's own
suggestions whatever the setting.

## 5. App

* **`/musical-dna`** (your own DNA). Entry: Profile → Musical DNA.
  * Hero: the top family and its share, a DNA strip and a legend.
  * Distribution: per family, a bar, its top subgenres and the artists
    behind it.
  * Diversity: a ring, the tier and family/subgenre counts.
  * Evolution: up to 6 sampled snapshots as strips, plus the families
    that moved ≥ 3 points since the first snapshot.
  * Sources: what the DNA is based on, with a link to edit picked genres.
  * Visibility: Everyone / Matches / Only me.
* **Other users.** Their profile shows a compact DNA card when their
  setting allows it. The full screen then hides evolution, sources and
  visibility.
* **Colours.** The leading family is violet; the others step down in
  white, so the design stays monochrome.
