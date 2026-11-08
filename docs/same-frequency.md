# VIBRA Same Frequency

People with a meaningful musical connection: not a list sorted by
percentage. Server: migration `20261109000000_same_frequency.sql`.
Ranking: `lib/domain/usecases/same_frequency.dart`. App: `/same-frequency`,
opened from the Social tab, under the affinity card.

## 1. Candidates

`get_same_frequency` builds on `get_affinity_feed`, so every existing rule
keeps applying:
* mutual consent to musical matching;
* blocks and test segments;
* people the user chose to "Ignore";
* existing or pending connections are left out.

Only pairs with affinity of 45 or more are considered.

## 2. Signals

| Signal | Source | Privacy rule |
|---|---|---|
| Genre overlap, related genres, shared subgenres | cached affinity pair (`docs/music-affinity-engine.md`) | existing consent |
| Artists in common | cached affinity pair | existing consent |
| Recently discovered artists, both | artists in the newest Musical DNA snapshot but not in one ≥ 28 days older, intersected | only if the other person's DNA visibility is Everyone or Matches |
| Same musical direction | genre families that grew ≥ 5 points in both people's DNA over the same window | same as above |
| Shared event interests | upcoming events both saved (going/maybe) | **only when both opted in** (`privacy_preferences.same_frequency_events`, off by default); saved events are otherwise private |
| Musical communities | communities both belong to (`get_shared_communities`, migration `20261111000000`) | community membership RLS: blocked people and other test segments never match |

* **Snapshot artists.** Since this release, DNA snapshots keep the ranked
  top artists (`dna.artists`). `get_musical_dna` strips that list for
  anyone other than the owner.
* **Discovery and direction start later.** Both need about 4 weeks of
  history before they can appear.

## 3. Ranking

```
strength = 0.50 × affinity/100
         + 0.15 × min(shared artists, 5)/5
         + 0.10 × min(shared discoveries, 3)/3
         + 0.10 × min(shared rising families, 2)/2
         + 0.10 × min(shared events, 2)/2
         + 0.05 × min(shared communities, 2)/2
```

* **Strong connection** (counted in "You've discovered N people"):
  affinity ≥ 65, or affinity ≥ 45 plus at least one other concrete signal.
* **Rotation.** `same_frequency_views` counts at most one view per person
  every 6 hours and forgets views after 60 days. Someone already shown is
  pushed down:
  * shown in the last 24 h: × 0.55;
  * shown in the last 72 h: × 0.8;
  * shown 3 or more times: a further × 0.85 for each view from the 3rd on
    (up to 5 times).

  Saved people are never pushed down.
* **Diversity.** People are picked one at a time. Each pick loses 0.12 for
  every person already picked whose main genre family is the same, so the
  list mixes sounds instead of repeating one.
* **Size.** Up to 12 people are shown. The list is ranked once per visit,
  so it stays stable while the user is looking at it.

## 4. Card and actions

Each card shows:
* the photo, name and affinity percentage;
* shared genres and artists in common;
* up to 3 reasons, most specific first: shared discoveries, shared
  direction, shared event, shared communities, then the affinity
  explanation.

The actions are:
* open the profile;
* Send Vibra, the existing connection request (the person then leaves
  the list);
* Message, shown only when the existing message permission allows it;
* Save / Saved;
* Discover shared artists, a sheet that opens events for each shared
  artist in Explore.

The **Saved** tab lists saved people (`get_saved_profiles`), up to 200.
Saved people and view counts are included in the personal data export and
deleted with the account.
