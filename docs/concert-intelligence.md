# VIBRA Concert Intelligence

Smarter event discovery built on the existing Ticketmaster catalogue.
Server: `recommend-events` (rewritten) and `_shared/event_recommendation.ts`.
Migration: `20261113000000_concert_intelligence.sql`. App: `/concerts`
(Concert Finder), opened from Home's "For you" → All.

## 1. What changed

| Before | Now |
|---|---|
| Spotify only. Users with only picked genres got an error. | Uses the Musical DNA (Spotify and/or picked genres) |
| Older keyword genre list | The same genre catalogue as the DNA and matching |
| Saved events and ticket clicks ignored | They count as previous interest |
| Home always sent Milan's coordinates | The real device position, else the user's own consented server location, else none (no distances shown) |
| Fixed 100 km search | A distance filter: 10–250 km or any |
| Scores without explanation | Reasons for every event |
| Prices always shown in euros | Shown only in the currency Ticketmaster published |

## 2. Scoring (`scoreEvent`)

```
A  artist   = rank weight of a matching Spotify top artist (by ID or name),
              or ½ × rank weight if the artist is on the user's top tracks
G  genre    = event genres (Ticketmaster → catalogue) vs. Musical DNA:
              subgenre share relative to the top subgenre, or
              0.8 × family share relative to the top family;
              ignored below 10% of the DNA
I  interest = 1 if the user saved or clicked tickets for this artist before,
              0.5 if they did so for ≥ 2 events of this genre family
relevance   = 1 − (1 − A)(1 − 0.8·G)(1 − 0.5·I)
total       = 0.60·relevance + 0.25·proximity + 0.15·soonness
```

* **Proximity** is 100 up to 25 km and falls to 0 at 250 km.
* **Soonness** falls from 100 (today) to 0 (in 180 days).
* **Relevance 0 means not recommended.** An event with no musical signal
  is never listed as "you might enjoy".
* **Reasons** come most specific first:
  * top artist (with rank), track artist, genre (with its DNA share),
    a saved artist, similar to saved events;
  * then distance (when both positions are known) and "in N days"
    (within 14 days).

Covered by `_shared/event_recommendation.test.ts`.

## 3. Filters

| Filter | Where it applies |
|---|---|
| Genre | the event's catalogue families. The chips are the user's top DNA families. |
| Artist | a text match on the artist name and the event title |
| Date | 7 days, 30 days, 3 months or any |
| Distance | 10–250 km from the origin. With no origin, distance can't be filtered and the screen says so. |
| Price | "from" price up to €30, €60 or €100. **Only events with a published EUR price**, as the screen says. |

## 4. Honest event data

* **Status, price, ticket link and genres** are shown exactly as stored
  from Ticketmaster. Nothing about availability is inferred: "From €X" is
  the published lowest face value, not stock.
* **Currency.** `events.price_currency` is stored by the sync. Existing
  priced events in eurozone countries were backfilled as EUR; any other
  price stays hidden until the next sync adds its currency.
* **Genres.** Event cards and the event detail show the published genres.

## 5. Notes

* `build.yaml` excludes `lib/core/music/genre_catalog.dart` from
  `build_runner`. Before, `--delete-conflicting-outputs` deleted the
  Python-generated `genre_catalog.g.dart`.
* `recommend-events` now uses the shared `recommend-events` rate limit
  (30 requests a minute).
