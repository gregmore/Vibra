// VIBRA Feed (docs/vibra-feed.md): what a post may contain.
//
// Licensing: as for Daily Vibe and Music Stories, only metadata, artwork
// hosted by Spotify's CDN and a link back are kept. No audio, ever.
import { classifyGenre } from "./music_affinity.ts";
import type { StoryItem } from "./music_stories.ts";

export const FEED_KINDS = [
  "song", "album", "playlist", "recommendation", "discovery", "review", "opinion", "concert_photo", "share",
] as const;
export type FeedKind = typeof FEED_KINDS[number];
export type ItemType = "track" | "album" | "artist" | "playlist";
export const ITEM_TYPES: readonly ItemType[] = ["track", "album", "artist", "playlist"];

/** Which item types each kind accepts (none: no music item). */
export const KIND_ITEM_TYPES: Record<FeedKind, readonly ItemType[]> = {
  song: ["track"],
  album: ["album"],
  playlist: ["playlist"],
  recommendation: ITEM_TYPES,
  discovery: ITEM_TYPES,
  review: ["track", "album"],
  opinion: [],
  concert_photo: [],
  share: [],
};

const MEDIA_PATH = /^[0-9a-f-]{36}\/[0-9a-f-]{36}\.png$/;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

const clean = (v: unknown, max: number) =>
  typeof v === "string" && v.trim() ? v.trim().slice(0, max) : null;

export type FeedInput = {
  kind: FeedKind;
  item_type: ItemType | null;
  body: string | null;
  rating: number | null;
  media_path: string | null;
  event_id: string | null;
  shared_post_id: string | null;
  visibility: "connections" | "everyone";
  comments_enabled: boolean;
};

/** Validates the client's fields (everything except the music item). */
export function parseFeedInput(body: Record<string, unknown>, userId: string): FeedInput | null {
  const kind = FEED_KINDS.find((k) => k === body.kind);
  if (!kind) return null;
  const allowed = KIND_ITEM_TYPES[kind];
  const itemType = allowed.find((t) => t === body.item_type) ?? (allowed.length === 1 ? allowed[0] : null);
  if (allowed.length && !itemType) return null;
  const text = clean(body.body, 2000);
  const rating = typeof body.rating === "number" && Number.isInteger(body.rating) && body.rating >= 1 && body.rating <= 5
    ? body.rating : null;
  const media = typeof body.media_path === "string" && MEDIA_PATH.test(body.media_path) &&
      body.media_path.startsWith(`${userId}/`) ? body.media_path : null;
  const shared = typeof body.shared_post_id === "string" && UUID.test(body.shared_post_id) ? body.shared_post_id : null;
  if (kind === "opinion" && !text) return null;
  if (kind === "review" && (!text || !rating)) return null;
  if (kind === "concert_photo" && !media) return null;
  if (kind === "share" && !shared) return null;
  return {
    kind,
    item_type: itemType,
    body: text,
    rating: kind === "review" ? rating : null,
    media_path: kind === "concert_photo" ? media : null,
    event_id: kind === "concert_photo" && typeof body.event_id === "string" && UUID.test(body.event_id)
      ? body.event_id : null,
    shared_post_id: kind === "share" ? shared : null,
    visibility: body.visibility === "connections" ? "connections" : "everyone",
    comments_enabled: body.comments_enabled !== false,
  };
}

/**
 * Catalogue genre keys (subgenres and their families) from provider genre
 * labels. Used for relevance only; unknown labels are dropped.
 */
export function genreKeys(labels: unknown[]): string[] {
  const keys = new Set<string>();
  for (const label of labels) {
    const g = typeof label === "string" ? classifyGenre(label) : null;
    if (!g) continue;
    keys.add(g.subgenre);
    keys.add(g.family);
  }
  return [...keys].slice(0, 12);
}

/** Lower-cased artist names, for matching with Musical DNA artists. */
export function artistKeys(names: unknown[]): string[] {
  return [...new Set(names.filter((n): n is string => typeof n === "string" && !!n.trim())
    .map((n) => n.trim().toLowerCase().slice(0, 100)))].slice(0, 5);
}

/** Artist ids (and names) behind a raw Spotify object, for genre lookups. */
// deno-lint-ignore no-explicit-any
export function artistsOf(type: ItemType, raw: any): { ids: string[]; names: string[]; genres: string[] } {
  if (type === "artist") {
    return { ids: [], names: [raw?.name], genres: Array.isArray(raw?.genres) ? raw.genres : [] };
  }
  if (type === "playlist") return { ids: [], names: [], genres: [] };
  const artists = Array.isArray(raw?.artists) ? raw.artists : [];
  return {
    ids: artists.map((a: { id?: unknown }) => a?.id).filter((id: unknown): id is string =>
      typeof id === "string" && /^[A-Za-z0-9]{22}$/.test(id)).slice(0, 3),
    names: artists.map((a: { name?: unknown }) => a?.name),
    genres: [],
  };
}

/** The payload of create_feed_post. */
export function feedPayload(
  input: FeedInput,
  item: StoryItem | null,
  genres: string[] = [],
  artists: string[] = [],
) {
  return {
    kind: input.kind,
    provider: item?.provider ?? null,
    item_type: item ? input.item_type : null,
    item_id: item?.item_id ?? null,
    title: item?.title ?? null,
    subtitle: item?.subtitle ?? null,
    artwork_url: item?.artwork_url ?? null,
    external_url: item?.external_url ?? null,
    media_path: input.media_path,
    event_id: input.event_id,
    body: input.body,
    rating: input.rating,
    genre_keys: genres,
    artist_keys: artists,
    shared_post_id: input.shared_post_id,
    visibility: input.visibility,
    comments_enabled: input.comments_enabled,
  };
}
