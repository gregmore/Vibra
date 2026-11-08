# VIBRA AI — personal music assistant

An optional assistant (spec section 17) that answers music questions using
the user's own Musical DNA and preferences, Spotify's public catalogue and
VIBRA's concerts and communities.

## What people can ask

The app suggests: artists similar to Travis Scott, underground Hip-Hop
artists, albums for my profile, why two artists sound alike, concerts that
match my interests, communities I might enjoy, new genres to discover. Any
music question works.

## Optional by design

- **Provider-neutral core.** Tools (`_shared/ai/tools.ts`), the answer
  check (`_shared/ai/answer.ts`) and the data layer (`_shared/ai/supabase_data.ts`)
  know nothing about the AI provider. Only `_shared/ai/anthropic_provider.ts`
  does, and it is loaded lazily by `_shared/ai/provider.ts`. Another provider
  only needs to implement `AssistantProvider`.
- **No provider, no problem.** Without `ANTHROPIC_API_KEY` (or with
  `VIBRA_AI_ENABLED=false`), `vibra-ai` reports `available: false`. The app
  hides the Home entry and the screen says the assistant isn't available.
  No other feature calls it or waits for it.
- **Off until the user turns it on.** `privacy_preferences.ai_assistant`
  defaults to false. The consent screen explains what is sent, to whom
  (Anthropic), and what never is. It can be turned off from the
  assistant's menu, and Privacy controls link to it.

## How answers stay grounded

The model gets seven read-only tools:

| Tool | Data | Source label |
| --- | --- | --- |
| `get_my_music_profile` | Musical DNA families/subgenres, top artists, picked genres | Musical DNA |
| `search_spotify` | artists, albums, tracks | Spotify |
| `get_artist_albums` | an artist's real albums | Spotify |
| `compare_artists` | two artists' genres mapped to VIBRA's catalogue, shared genres, similarity | Spotify + genre catalogue |
| `find_concerts` | upcoming events in VIBRA's catalogue (by artist, genre, a city the user named) | VIBRA concerts |
| `find_communities` | VIBRA communities by genre | VIBRA communities |
| `explore_genres` | VIBRA's genre catalogue and related families | genre catalogue |

Every tool result item has a `ref`. The final reply is structured JSON
(`answer`, `highlights`, `ideas`), and the server keeps as **verified** only
highlights whose `ref` a tool returned in this request. Their title, date,
link and image come from the tool result, never from the model. Anything
else is dropped (and counted). `ideas` are generated, can't be artists,
albums or events, and are shown as "not verified".

In the app:

- the answer text is always labelled "AI-generated · may contain
  mistakes";
- verified results are cards with their source ("Verified on Spotify",
  "From VIBRA's concert listings"…);
- ideas are listed apart as generated suggestions.

The instructions also require confirming every named artist, album or
track with Spotify, and naming no concert except one `find_concerts`
returned. Spotify has no "similar artists" endpoint available to new apps,
so candidates come from the model and are then checked on Spotify.

## Privacy

- **The user's own data only.** Every read uses the caller's own session
  (RLS applies). No other person's profile is read.
- **No location.** No GPS or coordinates are used. Concerts are filtered
  only by a city the user names in the question.
- **Spotify tokens are never exposed.** The catalogue is read with the
  app's client-credentials token; users' Spotify tokens are never read, and
  a test fails if the assistant code mentions them.
- **Conversations are not stored.** The app keeps the chat in memory and
  sends the last 10 turns (2,000 characters each) with each question. The
  server records only the time of each request, for limits, and deletes it
  after 2 days. Questions and answers are never logged.
- **Limits:** 6 questions a minute and 40 a day per user.
- Tool results are treated as data; instructions inside them are ignored.

## Provider details (Anthropic)

`claude-opus-5-5` (override with `VIBRA_AI_MODEL`), adaptive thinking at
`medium` effort, strict tool schemas, structured output for the final
reply, and server-side refusal fallback (`fallbacks: "default"`). A safety
decline is shown as "can't help with that"; at most 8 tool rounds per
question.

## Setup

Secrets (Edge Functions): `ANTHROPIC_API_KEY` (required to enable),
`VIBRA_AI_MODEL`, `VIBRA_AI_ENABLED`. Deploy `vibra-ai`. Migration
`20261120000000_vibra_ai.sql` (consent columns, `set_ai_assistant_consent`,
`begin_ai_assistant_request`, usage purge). See also
`supabase/PRODUCTION_SETUP.md`.
