// Daily Vibe track metadata (docs/daily-vibe.md).
//
// Licensing: only metadata (title, artists, album), the artwork URL hosted
// by Spotify's CDN (never downloaded or re-hosted) and a link back to the
// track on Spotify are kept. Audio and preview URLs are never stored or
// returned. Posts are displayed with Spotify attribution.

export type VibeTrack = {
  provider: "spotify" | "link";
  track_id: string | null;
  title: string;
  artist: string;
  album: string | null;
  artwork_url: string | null;
  external_url: string;
};

const SPOTIFY_ID = /^[A-Za-z0-9]{22}$/;
const ARTWORK_HOST = /^https:\/\/i\.scdn\.co\//;

/**
 * GET on the Spotify Web API with the app's client-credentials token.
 * `unavailable` when Spotify is not configured; `data: null` for unknown ids.
 */
export async function spotifyApi(
  path: string,
  token: string | null,
  wait: (ms: number) => Promise<void> = (ms) => new Promise((r) => setTimeout(r, ms)),
  fetcher: typeof fetch = fetch,
) {
  if (!token) return { unavailable: true as const };
  for (let attempt = 0; attempt < 2; attempt++) {
    const res = await fetcher(`https://api.spotify.com/v1${path}`, {
      headers: { Authorization: `Bearer ${token}` },
      signal: AbortSignal.timeout(10_000),
    });
    if (res.status === 429) {
      // Spotify's rate limit: honour Retry-After once if it is short;
      // otherwise report the provider unavailable instead of hammering it.
      const seconds = Number(res.headers.get("Retry-After") ?? "");
      await res.body?.cancel();
      if (attempt === 0 && Number.isFinite(seconds) && seconds >= 0 && seconds <= 3) {
        await wait(seconds * 1000);
        continue;
      }
      return { unavailable: true as const };
    }
    if (res.status === 404 || res.status === 400) return { data: null };
    if (!res.ok) throw new Error(`spotify_${res.status}`);
    return { data: await res.json() };
  }
  return { unavailable: true as const };
}

export function isSpotifyTrackId(id: unknown): id is string {
  return typeof id === "string" && SPOTIFY_ID.test(id);
}

const clean = (v: unknown, max: number) =>
  typeof v === "string" && v.trim() ? v.trim().slice(0, max) : null;

/** Maps a Spotify Web API track object; null when it is not usable. */
// deno-lint-ignore no-explicit-any
export function mapSpotifyTrack(raw: any): VibeTrack | null {
  if (!raw || !isSpotifyTrackId(raw.id)) return null;
  const title = clean(raw.name, 200);
  const artists = (Array.isArray(raw.artists) ? raw.artists : [])
    .map((a: { name?: unknown }) => clean(a?.name, 100))
    .filter((n: string | null): n is string => !!n);
  if (!title || artists.length === 0) return null;
  // Pick the image closest to 300 px from Spotify's CDN only.
  const images = (Array.isArray(raw.album?.images) ? raw.album.images : [])
    .filter((i: { url?: unknown }) => typeof i?.url === "string" && ARTWORK_HOST.test(i.url as string))
    .sort((a: { width?: number }, b: { width?: number }) =>
      Math.abs((a.width ?? 0) - 300) - Math.abs((b.width ?? 0) - 300));
  return {
    provider: "spotify",
    track_id: raw.id,
    title,
    artist: artists.slice(0, 3).join(", "),
    album: clean(raw.album?.name, 200),
    artwork_url: images[0]?.url ?? null,
    external_url: `https://open.spotify.com/track/${raw.id}`,
  };
}

const LINK_HOSTS = /^https:\/\/(music\.apple\.com|music\.youtube\.com|(www\.)?youtube\.com|youtu\.be|soundcloud\.com|[a-z0-9-]+\.bandcamp\.com|open\.spotify\.com)\//i;

/** A link to one of the supported music providers. */
export function isProviderLink(url: unknown): url is string {
  return typeof url === "string" && url.length <= 300 && LINK_HOSTS.test(url.trim());
}

/**
 * A song from another provider: a link plus the title and artist the user
 * typed. No artwork or audio is fetched from the link.
 */
export function linkTrack(url: unknown, title: unknown, artist: unknown): VibeTrack | null {
  const u = clean(url, 300);
  const t = clean(title, 200);
  const a = clean(artist, 100);
  if (!u || !LINK_HOSTS.test(u) || !t || !a) return null;
  return { provider: "link", track_id: null, title: t, artist: a, album: null, artwork_url: null, external_url: u };
}

export function validQuery(q: unknown): string | null {
  const v = clean(q, 100);
  return v && v.length >= 1 ? v : null;
}
