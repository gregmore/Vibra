import { optionalEnv, requireEnv } from "./env.ts";

type SpotifyAppToken = {
  access_token: string;
  token_type: string;
  expires_in: number;
};

let cachedToken: { token: string; expiresAt: number } | null = null;

export async function getSpotifyAppAccessToken(): Promise<string | null> {
  const clientId = optionalEnv("SPOTIFY_CLIENT_ID");
  const clientSecret = optionalEnv("SPOTIFY_CLIENT_SECRET");
  if (!clientId || !clientSecret) return null;

  const now = Date.now();
  if (cachedToken && cachedToken.expiresAt > now + 30_000) {
    return cachedToken.token;
  }

  const body = new URLSearchParams({ grant_type: "client_credentials" });
  const basic = btoa(`${clientId}:${clientSecret}`);

  const res = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      "Authorization": `Basic ${basic}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body,
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Spotify app token failed: ${res.status} ${text}`);
  }

  const json = (await res.json()) as SpotifyAppToken;
  const expiresAt = now + (json.expires_in * 1000);
  cachedToken = { token: json.access_token, expiresAt };
  return json.access_token;
}

export async function fetchSpotifyArtistsByIds(
  ids: string[],
): Promise<
  Array<{
    id: string;
    followers?: { total?: number };
    genres?: string[];
  }>
> {
  if (ids.length === 0) return [];

  const token = await getSpotifyAppAccessToken();
  if (!token) {
    // Se non abbiamo credenziali server-side, non possiamo arricchire.
    return [];
  }

  const chunks: string[][] = [];
  for (let i = 0; i < ids.length; i += 50) {
    chunks.push(ids.slice(i, i + 50));
  }

  const out: Array<{ id: string; followers?: { total?: number }; genres?: string[] }> = [];
  for (const chunk of chunks) {
    const url = `https://api.spotify.com/v1/artists?ids=${encodeURIComponent(chunk.join(","))}`;
    const res = await fetch(url, {
      headers: {
        "Authorization": `Bearer ${token}`,
      },
    });
    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Spotify artists fetch failed: ${res.status} ${text}`);
    }
    const json = await res.json();
    const artists = (json?.artists ?? []) as any[];
    for (const a of artists) {
      if (a?.id) out.push(a);
    }
  }
  return out;
}

