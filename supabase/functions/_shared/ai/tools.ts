// VIBRA AI tools (docs/vibra-ai.md). Every tool reads real data and returns
// compact JSON for the model. Each result item carries a `ref`; the
// registry remembers it so the final answer can only show as "verified"
// what a tool actually returned in this request.
import { GENRE_CATALOG } from "../genre_catalog.ts";
import { classifyGenre, subgenreSimilarity } from "../music_affinity.ts";
import { eventGenres } from "../event_recommendation.ts";
import type { AssistantData, VerifiedItem } from "./types.ts";

const SPOTIFY_ID = /^[A-Za-z0-9]{22}$/;
const ARTWORK = /^https:\/\/(i\.scdn\.co|mosaic\.scdn\.co|image-cdn-[a-z0-9]+\.spotifycdn\.com)\//;
const FAMILIES = new Set<string>(GENRE_CATALOG.families.map((f) => f.key));
const SUBGENRES = new Map<string, { family: string; label: string }>(
  GENRE_CATALOG.subgenres.map((s) => [s.key, { family: s.family, label: s.label }]),
);
const FAMILY_LABEL = new Map<string, string>(GENRE_CATALOG.families.map((f) => [f.key, f.label]));

export const genreLabel = (key: string) => SUBGENRES.get(key)?.label ?? FAMILY_LABEL.get(key) ?? key;

export class Registry {
  readonly items = new Map<string, VerifiedItem>();
  add(item: VerifiedItem) {
    if (!this.items.has(item.ref)) this.items.set(item.ref, item);
    return item.ref;
  }
}

const nullable = (schema: Record<string, unknown>) => ({ anyOf: [schema, { type: "null" }] });
const genreKeysSchema = {
  type: "array",
  items: { type: "string" },
  description: "Genre keys from get_my_music_profile or explore_genres (e.g. \"hip-hop\", \"underground-hip-hop\").",
};

/** Tool definitions (provider-neutral JSON Schema, strict-compatible). */
export const TOOL_DEFINITIONS = [
  {
    name: "get_my_music_profile",
    description:
      "The user's own music profile: Musical DNA genre families and subgenres with percentages, their top artists' names, and genres they picked. Call this before personal recommendations. Returns has_data=false when there is no profile yet.",
    input_schema: { type: "object", properties: {}, required: [], additionalProperties: false },
  },
  {
    name: "search_spotify",
    description:
      "Search Spotify's catalogue for artists, albums or tracks. Use it to confirm that every artist, album or track you mention exists, and to get its real genres, release year and link. Results are facts; anything not found here must not be named.",
    input_schema: {
      type: "object",
      properties: {
        type: { type: "string", enum: ["artist", "album", "track"] },
        query: { type: "string", description: "Artist, album or track name (optionally with the artist)." },
      },
      required: ["type", "query"],
      additionalProperties: false,
    },
  },
  {
    name: "get_artist_albums",
    description: "An artist's albums from Spotify (real discography: titles and release years). Use the artist id from search_spotify.",
    input_schema: {
      type: "object",
      properties: { artist_id: { type: "string" } },
      required: ["artist_id"],
      additionalProperties: false,
    },
  },
  {
    name: "compare_artists",
    description:
      "Compares two artists' Spotify genres, mapped onto VIBRA's genre catalogue: shared genres, shared families and a similarity from 0 to 1. Use it to ground an explanation of why two artists sound alike. Use artist ids from search_spotify.",
    input_schema: {
      type: "object",
      properties: { artist_ids: { type: "array", items: { type: "string" } } },
      required: ["artist_ids"],
      additionalProperties: false,
    },
  },
  {
    name: "find_concerts",
    description:
      "Upcoming concerts from VIBRA's events catalogue, filtered by artist name, genre keys and/or a city the user named. These are the only concerts that exist for you: never mention any other event, date, venue or ticket.",
    input_schema: {
      type: "object",
      properties: {
        artist: nullable({ type: "string" }),
        genre_keys: genreKeysSchema,
        city: nullable({ type: "string", description: "Only a city the user explicitly named." }),
      },
      required: ["artist", "genre_keys", "city"],
      additionalProperties: false,
    },
  },
  {
    name: "find_communities",
    description:
      "VIBRA communities matching genre keys, with member counts and whether the user already joined. The only communities you may suggest.",
    input_schema: {
      type: "object",
      properties: { genre_keys: genreKeysSchema },
      required: ["genre_keys"],
      additionalProperties: false,
    },
  },
  {
    name: "explore_genres",
    description:
      "VIBRA's genre catalogue: with family=null, every family; with a family key, its subgenres and the families most related to it. Use it to suggest genres to discover; only these genre keys exist.",
    input_schema: {
      type: "object",
      properties: { family: nullable({ type: "string" }) },
      required: ["family"],
      additionalProperties: false,
    },
  },
] as const;

export type ToolName = typeof TOOL_DEFINITIONS[number]["name"];

const str = (v: unknown, max = 200) => typeof v === "string" && v.trim() ? v.trim().slice(0, max) : null;
const keys = (v: unknown) =>
  Array.isArray(v) ? v.filter((k): k is string => typeof k === "string" && (SUBGENRES.has(k) || FAMILIES.has(k))).slice(0, 12) : [];
// deno-lint-ignore no-explicit-any
const image = (images: any): string | null => {
  const list = Array.isArray(images) ? images : [];
  const ok = list.find((i: { url?: unknown }) => typeof i?.url === "string" && ARTWORK.test(i.url as string));
  return ok?.url ?? null;
};
const familiesOfLabels = (labels: unknown[]) => {
  const subs = new Set<string>(), fams = new Set<string>();
  for (const l of labels) {
    const c = typeof l === "string" ? classifyGenre(l) : null;
    if (c) {
      subs.add(c.subgenre);
      fams.add(c.family);
    }
  }
  return { subgenres: [...subs], families: [...fams] };
};

/** Runs one tool. Errors are returned as data so the model can adapt. */
export async function runTool(
  name: string,
  input: Record<string, unknown>,
  data: AssistantData,
  registry: Registry,
): Promise<unknown> {
  switch (name) {
    case "get_my_music_profile": {
      const p = await data.myProfile();
      for (const g of [...p.families, ...p.subgenres]) {
        registry.add({
          ref: `genre:${g.key}`, kind: "genre", title: genreLabel(g.key), subtitle: `${g.percent}%`,
          url: null, image_url: null, date: null, source: "musical_dna",
        });
      }
      return {
        has_data: p.has_data,
        families: p.families.map((f) => ({ ref: `genre:${f.key}`, key: f.key, label: genreLabel(f.key), percent: f.percent })),
        subgenres: p.subgenres.map((s) => ({ ref: `genre:${s.key}`, key: s.key, label: genreLabel(s.key), percent: s.percent })),
        top_artists: p.top_artists,
        picked_genres: p.picked_genres,
      };
    }
    case "search_spotify": {
      const type = ["artist", "album", "track"].find((t) => t === input.type);
      const q = str(input.query, 100);
      if (!type || !q) return { error: "invalid_input" };
      const r = await data.spotify(`/search?type=${type}&limit=6&q=${encodeURIComponent(q)}`);
      if ("unavailable" in r) return { error: "spotify_unavailable" };
      // deno-lint-ignore no-explicit-any
      const raw = (r.data?.[`${type}s`]?.items ?? []) as any[];
      return {
        results: raw.filter((x) => x && SPOTIFY_ID.test(x.id) && typeof x.name === "string").map((x) => {
          const artists = (x.artists ?? []).map((a: { name?: string }) => a?.name).filter(Boolean).slice(0, 3);
          const year = typeof (x.release_date ?? x.album?.release_date) === "string"
            ? String(x.release_date ?? x.album.release_date).slice(0, 4) : null;
          const item: VerifiedItem = {
            ref: `spotify:${type}:${x.id}`,
            kind: type as "artist" | "album" | "track",
            title: String(x.name).slice(0, 200),
            subtitle: type === "artist"
              ? (x.genres ?? []).slice(0, 3).join(", ") || null
              : [artists.join(", "), year].filter(Boolean).join(" · ") || null,
            url: `https://open.spotify.com/${type}/${x.id}`,
            image_url: image(type === "track" ? x.album?.images : x.images),
            date: null,
            source: "spotify",
          };
          registry.add(item);
          return {
            ref: item.ref, id: x.id, name: item.title,
            ...(type === "artist" ? { genres: (x.genres ?? []).slice(0, 8) } : { artists, year }),
          };
        }),
      };
    }
    case "get_artist_albums": {
      const id = str(input.artist_id, 40);
      if (!id || !SPOTIFY_ID.test(id)) return { error: "invalid_artist_id" };
      const r = await data.spotify(`/artists/${id}/albums?include_groups=album&limit=20`);
      if ("unavailable" in r) return { error: "spotify_unavailable" };
      // deno-lint-ignore no-explicit-any
      const items = (r.data?.items ?? []) as any[];
      if (!items.length) return { albums: [] };
      return {
        albums: items.filter((a) => a && SPOTIFY_ID.test(a.id)).map((a) => {
          const year = typeof a.release_date === "string" ? a.release_date.slice(0, 4) : null;
          const ref = registry.add({
            ref: `spotify:album:${a.id}`, kind: "album", title: String(a.name).slice(0, 200),
            subtitle: [(a.artists ?? []).map((x: { name?: string }) => x?.name).filter(Boolean).slice(0, 2).join(", "), year]
              .filter(Boolean).join(" · ") || null,
            url: `https://open.spotify.com/album/${a.id}`, image_url: image(a.images), date: null, source: "spotify",
          });
          return { ref, name: a.name, year };
        }),
      };
    }
    case "compare_artists": {
      const ids = Array.isArray(input.artist_ids)
        ? input.artist_ids.filter((x): x is string => typeof x === "string" && SPOTIFY_ID.test(x)).slice(0, 2) : [];
      if (ids.length !== 2) return { error: "need_two_artist_ids" };
      const r = await data.spotify(`/artists?ids=${ids.join(",")}`);
      if ("unavailable" in r) return { error: "spotify_unavailable" };
      // deno-lint-ignore no-explicit-any
      const artists = ((r.data?.artists ?? []) as any[]).filter(Boolean);
      if (artists.length !== 2) return { error: "artist_not_found" };
      const [a, b] = artists.map((x) => ({ x, g: familiesOfLabels(x.genres ?? []) }));
      for (const { x } of [a, b]) {
        registry.add({
          ref: `spotify:artist:${x.id}`, kind: "artist", title: String(x.name).slice(0, 200),
          subtitle: (x.genres ?? []).slice(0, 3).join(", ") || null, url: `https://open.spotify.com/artist/${x.id}`,
          image_url: image(x.images), date: null, source: "spotify",
        });
      }
      let best = 0;
      for (const s of a.g.subgenres) for (const t of b.g.subgenres) best = Math.max(best, subgenreSimilarity(s, t));
      return {
        artists: [a, b].map(({ x, g }) => ({
          ref: `spotify:artist:${x.id}`, name: x.name, spotify_genres: (x.genres ?? []).slice(0, 10),
          vibra_genres: g.subgenres.map(genreLabel),
        })),
        shared_genres: a.g.subgenres.filter((s) => b.g.subgenres.includes(s)).map(genreLabel),
        shared_families: a.g.families.filter((f) => b.g.families.includes(f)).map(genreLabel),
        genre_similarity: Math.round(best * 100) / 100,
        note: "Spotify genre tags are coarse; similarity in sound (production, flow, era) is your interpretation.",
      };
    }
    case "find_concerts": {
      const wanted = keys(input.genre_keys);
      const artist = str(input.artist, 100);
      const rows = await data.upcomingEvents({ artist, city: str(input.city, 80) });
      const matched = rows.filter((e) => {
        if (!wanted.length || artist) return true;
        const g = eventGenres(e.genres ?? []);
        return [...g.subgenres, ...g.families].some((k) => wanted.includes(k));
      }).slice(0, 10);
      return {
        concerts: matched.map((e) => {
          const ref = registry.add({
            ref: `event:${e.id}`, kind: "event", title: e.name.slice(0, 200),
            subtitle: [e.artist_name, e.venue_name, e.city].filter(Boolean).join(" · ") || null,
            url: e.ticket_url, image_url: e.image_url, date: e.event_date, source: "vibra_events",
          });
          return { ref, name: e.name, artist: e.artist_name, venue: e.venue_name, city: e.city, date: e.event_date };
        }),
        note: matched.length ? undefined : "No matching upcoming concerts in VIBRA's catalogue.",
      };
    }
    case "find_communities": {
      const wanted = keys(input.genre_keys);
      const all = await data.communities();
      const matched = all.filter((c) =>
        !wanted.length || (c.genre_key && wanted.includes(c.genre_key)) || (c.genre_family && wanted.includes(c.genre_family))
      ).slice(0, 8);
      return {
        communities: matched.map((c) => {
          const ref = registry.add({
            ref: `community:${c.id}`, kind: "community", title: c.name.slice(0, 120),
            subtitle: `${c.member_count}`, url: null, image_url: null, date: null, source: "vibra_communities",
          });
          return { ref, name: c.name, description: c.description.slice(0, 200), members: c.member_count, joined: c.my_role != null };
        }),
      };
    }
    case "explore_genres": {
      const family = str(input.family, 40);
      if (!family) {
        return {
          families: GENRE_CATALOG.families.map((f) => {
            registry.add({ ref: `genre:${f.key}`, kind: "genre", title: f.label, subtitle: null, url: null, image_url: null, date: null, source: "genre_catalog" });
            return { ref: `genre:${f.key}`, key: f.key, label: f.label };
          }),
        };
      }
      if (!FAMILIES.has(family)) return { error: "unknown_family" };
      const related = (GENRE_CATALOG.relations as readonly (readonly [string, string, number])[])
        .filter(([a, b]) => a === family || b === family)
        .map(([a, b, w]) => ({ key: a === family ? b : a, weight: w }))
        .sort((x, y) => y.weight - x.weight);
      const subgenres = (GENRE_CATALOG.subgenres as readonly { key: string; family: string; label: string }[])
        .filter((s) => s.family === family);
      for (const s of subgenres) {
        registry.add({ ref: `genre:${s.key}`, kind: "genre", title: s.label, subtitle: genreLabel(family), url: null, image_url: null, date: null, source: "genre_catalog" });
      }
      for (const r of related) {
        registry.add({ ref: `genre:${r.key}`, kind: "genre", title: genreLabel(r.key), subtitle: null, url: null, image_url: null, date: null, source: "genre_catalog" });
      }
      return {
        family: { key: family, label: genreLabel(family) },
        subgenres: subgenres.map((s) => ({ ref: `genre:${s.key}`, key: s.key, label: s.label })),
        related_families: related.map((r) => ({ ref: `genre:${r.key}`, key: r.key, label: genreLabel(r.key), closeness: r.weight })),
      };
    }
    default:
      return { error: "unknown_tool" };
  }
}
