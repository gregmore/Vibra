// Music Stories (docs/music-stories.md): what a story may contain.
//
// Licensing: as for Daily Vibe, only metadata, artwork hosted by Spotify's
// CDN (never downloaded or re-hosted) and a link back are kept. Audio and
// preview URLs are never stored or returned.
import { isProviderLink, mapSpotifyTrack } from "./spotify_tracks.ts";

export const STORY_KINDS = ["now_playing", "artist", "album", "playlist", "concert_photo", "opinion"] as const;
export type StoryKind = typeof STORY_KINDS[number];
export const BACKGROUNDS = ["aurora", "sunset", "ocean", "ember", "mono"] as const;

/** The Spotify search type behind each music kind. */
export const SEARCH_TYPES: Record<string, "track" | "artist" | "album" | "playlist"> = {
  now_playing: "track", artist: "artist", album: "album", playlist: "playlist",
};

export type StoryItem = {
  provider: "spotify" | "link";
  item_id: string | null;
  title: string;
  subtitle: string | null;
  artwork_url: string | null;
  external_url: string;
};

const SPOTIFY_ID = /^[A-Za-z0-9]{22}$/;
const ARTWORK_HOST = /^https:\/\/(i\.scdn\.co|mosaic\.scdn\.co|image-cdn-[a-z0-9]+\.spotifycdn\.com)\//;
const MEDIA_PATH = /^[0-9a-f-]{36}\/[0-9a-f-]{36}\.png$/;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

const clean = (v: unknown, max: number) =>
  typeof v === "string" && v.trim() ? v.trim().slice(0, max) : null;

// deno-lint-ignore no-explicit-any
function artwork(images: any): string | null {
  const list = (Array.isArray(images) ? images : [])
    .filter((i: { url?: unknown }) => typeof i?.url === "string" && ARTWORK_HOST.test(i.url as string))
    .sort((a: { width?: number }, b: { width?: number }) =>
      Math.abs((a.width ?? 300) - 300) - Math.abs((b.width ?? 300) - 300));
  return list[0]?.url ?? null;
}

/** Maps a Spotify object of the given search type; null when unusable. */
// deno-lint-ignore no-explicit-any
export function mapSpotifyItem(type: string, raw: any): StoryItem | null {
  if (!raw || typeof raw.id !== "string" || !SPOTIFY_ID.test(raw.id)) return null;
  if (type === "track") {
    const t = mapSpotifyTrack(raw);
    return t && {
      provider: "spotify", item_id: t.track_id, title: t.title,
      subtitle: t.album ? `${t.artist} · ${t.album}`.slice(0, 300) : t.artist,
      artwork_url: t.artwork_url, external_url: t.external_url,
    };
  }
  const title = clean(raw.name, 200);
  if (!title) return null;
  let subtitle: string | null = null;
  if (type === "artist") {
    const genres = (Array.isArray(raw.genres) ? raw.genres : []).filter((g: unknown) => typeof g === "string");
    subtitle = genres.length ? genres.slice(0, 3).join(", ") : null;
  } else if (type === "album") {
    const artists = (Array.isArray(raw.artists) ? raw.artists : [])
      .map((a: { name?: unknown }) => clean(a?.name, 100)).filter((n: string | null): n is string => !!n);
    if (!artists.length) return null;
    const year = typeof raw.release_date === "string" ? raw.release_date.slice(0, 4) : "";
    subtitle = [artists.slice(0, 3).join(", "), /^\d{4}$/.test(year) ? year : null].filter(Boolean).join(" · ");
  } else if (type === "playlist") {
    // Only public playlists are returned by client-credentials search.
    if (raw.public === false) return null;
    subtitle = clean(raw.owner?.display_name, 100);
  } else {
    return null;
  }
  return {
    provider: "spotify", item_id: raw.id, title, subtitle,
    artwork_url: artwork(type === "album" || type === "artist" || type === "playlist" ? raw.images : null),
    external_url: `https://open.spotify.com/${type}/${raw.id}`,
  };
}

/** A music item from another provider: a link plus the text the user typed. */
export function linkItem(url: unknown, title: unknown, subtitle: unknown): StoryItem | null {
  const t = clean(title, 200);
  if (!isProviderLink(url) || !t) return null;
  return {
    provider: "link", item_id: null, title: t, subtitle: clean(subtitle, 300),
    artwork_url: null, external_url: url.trim(),
  };
}

export type StoryInput = {
  kind: StoryKind;
  body: string | null;
  background: string;
  visibility: "connections" | "everyone" | null;
  allow_replies: boolean | null;
  media_path: string | null;
  event_id: string | null;
};

/**
 * Validates the client's story fields (everything except the music item).
 * A photo must be in the caller's own folder of the story-media bucket.
 */
export function parseStoryInput(body: Record<string, unknown>, userId: string): StoryInput | null {
  const kind = STORY_KINDS.find((k) => k === body.kind);
  if (!kind) return null;
  const text = clean(body.body, 300);
  const media = typeof body.media_path === "string" && MEDIA_PATH.test(body.media_path) &&
      body.media_path.startsWith(`${userId}/`) ? body.media_path : null;
  if (kind === "opinion" && !text) return null;
  if (kind === "concert_photo" && !media) return null;
  return {
    kind,
    body: text,
    background: BACKGROUNDS.find((b) => b === body.background) ?? "aurora",
    visibility: body.visibility === "everyone" ? "everyone" : body.visibility === "connections" ? "connections" : null,
    allow_replies: typeof body.allow_replies === "boolean" ? body.allow_replies : null,
    media_path: kind === "concert_photo" ? media : null,
    event_id: kind === "concert_photo" && typeof body.event_id === "string" && UUID.test(body.event_id)
      ? body.event_id : null,
  };
}

/** The payload of create_music_story. */
export function storyPayload(input: StoryInput, item: StoryItem | null) {
  return {
    kind: input.kind,
    provider: item?.provider ?? null,
    item_id: item?.item_id ?? null,
    title: item?.title ?? null,
    subtitle: item?.subtitle ?? null,
    artwork_url: item?.artwork_url ?? null,
    external_url: item?.external_url ?? null,
    media_path: input.media_path,
    event_id: input.event_id,
    body: input.body,
    background: input.background,
    visibility: input.visibility,
    allow_replies: input.allow_replies,
  };
}
