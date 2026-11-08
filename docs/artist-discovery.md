# Discover my next artist

An artist discovery engine (spec section 18). Home → "Discover my next
artist"; saved artists are also in Profile.

## What it recommends

Up to 30 artists, in five kinds, interleaved so no kind dominates:

| Kind | Where it comes from | Share |
| --- | --- | --- |
| Similar | artists in your top subgenres | 8 |
| Collaborations | featured artists on your favourite artists' recent releases | 6 |
| Emerging | popularity 25–49 and under 250k followers | 6 |
| Underground | popularity under 25 | 5 |
| New genres | artists in families next to yours in VIBRA's genre catalogue | 5 |

Each card says why it is there, using facts only: "Collaborated with Travis
Scott", "Shares your Trap", "A step into R&B".

## Signals

| Spec signal | How it is used |
| --- | --- |
| Favourite artists | top artists (Spotify sync) seed the collaboration search, and are never recommended back |
| Genre compatibility | catalogue similarity between the candidate's genres and your profile |
| Subgenre relationships | sibling subgenres score lower than exact matches; related families drive exploration |
| Musical profile | Musical DNA families and subgenres, plus genres you picked |
| Previously discovered artists | artists of songs in your Discoveries are excluded (you know them now) |
| User feedback | see below |

Less popular artists get a small bonus, so discovery beats the obvious. No
more than 3 artists share a main subgenre, and no more than 2 come from the
same seed artist.

## Feedback

On every card: **Like**, **Save for later**, **Already know**, **Not
interested**.

- **Like / Save for later:** the artist leaves the recommendations (saved
  ones are in "Saved artists"), their genres count as learned taste, and
  liked or saved artists become seeds for collaborations.
- **Already know:** the artist is never recommended again.
- **Not interested:** the artist is never recommended again, their genres
  count against similar artists, and a style dismissed twice is dropped
  (except for direct collaborators).
- An artist shown 3 times without an answer is rested (counted at most once
  every 6 hours, and kept across refreshes).

These rules are enforced in the database too: `save_artist_recommendations`
refuses "not interested" and "known" artists, and `get_artist_recommendations`
filters them.

## How it runs

`discover-artists` (Edge Function, user JWT):

1. reads the engine input (`get_artist_discovery_input`, service role);
2. returns the cached recommendations if they are under 12 hours old (a
   manual refresh is allowed every 2 minutes, 6 a minute at most);
3. otherwise it gathers candidates from Spotify with the **app's**
   client-credentials token (never a user's Spotify token):
   - collaborators on up to 6 seed artists' recent releases;
   - two searches per top subgenre (one deeper, for less popular artists);
   - searches in up to 2 neighbouring families;
4. scores and diversifies them with the pure engine
   (`_shared/artist_discovery.ts`) and saves them.

A failed Spotify lookup only loses that source of candidates. Spotify's
related-artists and recommendations endpoints aren't available to new apps,
so collaborations and genre searches stand in for them. If Spotify is
unavailable, the last recommendations stay visible.

## Data

Migration `20261121000000_artist_discovery.sql`: `artist_feedback`,
`artist_recommendations`, `set_artist_feedback`,
`mark_artist_recommendations_shown`, `save_artist_recommendations`,
`get_artist_discovery_input`, `get_artist_recommendations`, rate limits and
personal data export. Both tables are readable only by their owner.
