# Taste Evolution

A historical view of the user's Musical DNA (spec section 19). Musical DNA →
"See how your taste evolved".

## Where the history comes from

Only real data:

- **Musical DNA snapshots:** one per day, written by the existing DNA
  engine whenever the profile is recalculated, kept for 400 days. Taste
  Evolution adds no new collection; it reads what is already stored.
- **Community joins:** `community_members.joined_at`.

Nothing is estimated, interpolated or back-filled. A day with no snapshot
is simply absent.

## What it shows

Pick a period: 1 month, 3 months, 6 months, 1 year.

- **Headline:** "Your musical taste has evolved over the last 3 months", or
  "stayed steady". It counts as evolved when at least 10 percentage points
  of the genre mix moved, or 2+ new subgenres appeared.
- **Dates:** the dates of the two snapshots compared are always shown. If
  history is shorter than the period, the screen says the history starts on
  that date and compares from there.
- **Then and now:** both DNA bands, then paired bars per family
  ("30% → 0%").
- **Along the way:** up to 12 real snapshots spread across the period.
- **New genres discovered:** subgenres at 3% or more now that were absent
  from the baseline.
- **Rising favourites:** top-10 artists that are new, or rose 5+ places
  ("#15 → #9"). This needs Spotify; without it the screen says so.
- **What you listened to more before:** families that were 10%+ and fell to
  half or less, and former top-5 artists no longer in the top 15.
- **Communities you joined:** with their real join dates.

With a single snapshot, the screen says there isn't enough history yet and
when it started. It never shows an empty comparison as if it were data.

## Turning history off

"Keep my taste history" (on by default, as before this feature) is at the
bottom of the screen. Turning it off asks for confirmation, then:

- deletes all past snapshots (the current DNA stays);
- from then on `save_musical_dna` keeps only today's snapshot.

Features that compare taste over time (Taste Evolution, Same Frequency's
"evolving together") have nothing to compare until history is turned back
on. Turning it on starts a new history from that day.

## Data

Migration `20261122000000_taste_evolution.sql`:

- `privacy_preferences.taste_history`;
- `save_musical_dna` redefined to respect it;
- `set_taste_history(enabled)`;
- `get_taste_evolution(days)`, owner-only, SECURITY INVOKER: it returns
  the current snapshot, the baseline (the newest snapshot at least `days`
  old, or the oldest one), `full_period`, a sampled timeline and the
  communities joined since the baseline.

The comparisons are in `lib/domain/entities/taste_evolution.dart`, with
unit tests.
