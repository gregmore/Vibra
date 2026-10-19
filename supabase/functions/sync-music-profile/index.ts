import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { decryptToken, encryptToken } from "../_shared/token-crypto.ts";
import { loadTopGenres, SpotifyRequestError } from "./genres.ts";
import { rejectDisabledSpotify, spotifyUnavailableResponse } from "../_shared/spotify-feature.ts";

function createUserClient(req: Request) {
  const url = requireEnv("SUPABASE_URL");
  const anon = requireEnv("SUPABASE_ANON_KEY");

  return createClient(url, anon, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: {
      headers: {
        Authorization: req.headers.get("Authorization") ?? "",
      },
    },
  });
}

async function refreshSpotifyAccessToken(refreshToken: string) {
  const clientId = requireEnv("SPOTIFY_CLIENT_ID");
  const clientSecret = requireEnv("SPOTIFY_CLIENT_SECRET");
  const basic = btoa(`${clientId}:${clientSecret}`);

  const response = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${basic}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: refreshToken,
    }),
  });

  const json = await response.json();
  if (!response.ok) {
    throw new Error(`Spotify refresh failed: ${response.status} ${JSON.stringify(json)}`);
  }

  return json as {
    access_token: string;
    refresh_token?: string;
    expires_in?: number;
  };
}

async function spotifyGet(
  path: string,
  credentials: { accessToken: string; refreshToken: string | null; spotifyUserId: string; connectedAt: string },
  userId: string,
  supabase: any
) {
  let response = await fetch(`https://api.spotify.com/v1${path}`, {
    headers: { Authorization: `Bearer ${credentials.accessToken}` },
  });

  if (response.status === 401 && credentials.refreshToken) {
    const refreshed = await refreshSpotifyAccessToken(credentials.refreshToken);
    credentials.accessToken = refreshed.access_token;
    credentials.refreshToken = refreshed.refresh_token ?? credentials.refreshToken;

    const { data: saved, error: saveError } = await supabase.rpc("refresh_spotify_connection", {
      p_user_id: userId,
      p_spotify_user_id: credentials.spotifyUserId,
      p_connected_at: credentials.connectedAt,
      p_access_token_ciphertext: await encryptToken(credentials.accessToken),
      p_refresh_token_ciphertext: refreshed.refresh_token ? await encryptToken(refreshed.refresh_token) : null,
      p_token_expires_at: new Date(Date.now() + (refreshed.expires_in ?? 3600) * 1000).toISOString(),
    });
    if (saveError?.code === "PT503") throw new SpotifyRequestError(503, "spotify_temporarily_unavailable");
    if (saveError || saved !== true) throw new SpotifyRequestError(409, "Spotify connection changed or disconnected");

    response = await fetch(`https://api.spotify.com/v1${path}`, {
      headers: { Authorization: `Bearer ${credentials.accessToken}` },
    });
  }

  if (!response.ok) {
    const text = await response.text();
    throw new SpotifyRequestError(response.status, `Spotify GET ${path} failed: ${response.status} ${text}`);
  }

  return await response.json();
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "method_not_allowed" }), {
    status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
  const rejected = await rejectRevokedSession(req, "sync-music-profile");
  if (rejected) return rejected;

  try {
    const userClient = createUserClient(req);
    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const unavailable = rejectDisabledSpotify();
    if (unavailable) return unavailable;

    const supabase = createSupabaseServiceClient();
    const { data: userRow, error: userRowError } = await supabase
      .from("spotify_connections")
      .select("spotify_user_id, connected_at, access_token_ciphertext, refresh_token_ciphertext")
      .eq("user_id", authData.user.id)
      .maybeSingle();

    if (userRowError) throw userRowError;
    if (!userRow?.access_token_ciphertext) {
      return new Response(JSON.stringify({ error: "spotify_not_connected" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const credentials = {
      accessToken: await decryptToken(userRow.access_token_ciphertext as string),
      refreshToken: userRow.refresh_token_ciphertext
        ? await decryptToken(userRow.refresh_token_ciphertext as string)
        : null,
      spotifyUserId: userRow.spotify_user_id,
      connectedAt: userRow.connected_at,
    };

    try {
      const topArtistsRes = await spotifyGet(
        "/me/top/artists?limit=50&time_range=medium_term",
        credentials,
        authData.user.id,
        supabase
      );
      const topTracksRes = await spotifyGet(
        "/me/top/tracks?limit=50&time_range=medium_term",
        credentials,
        authData.user.id,
        supabase
      );

      const topArtists = ((topArtistsRes.items ?? []) as any[]).map((artist, index) => ({
        id: artist.id,
        name: artist.name,
        score: Math.max(100 - index, 0),
      }));

      const topTracks = ((topTracksRes.items ?? []) as any[]).map((track, index) => ({
        id: track.id,
        name: track.name,
        artist: Array.isArray(track.artists) && track.artists.length > 0 ? track.artists[0].name : null,
        score: Math.max(100 - index, 0),
      }));

      const topGenres = await loadTopGenres(
        topArtistsRes.items ?? [],
        (id) => spotifyGet(
          `/artists/${encodeURIComponent(id)}`,
          credentials,
          authData.user.id,
          supabase,
        ),
      );

      const trackIds = ((topTracksRes.items ?? []) as any[])
        .map((t: any) => t.id)
        .filter(Boolean)
        .slice(0, 50)
        .join(",");

      let embedding: string | null = null;
      let rawAudioFeatures = null;

      if (trackIds.length > 0) {
        try {
          const audioFeaturesRes = await spotifyGet(
            `/audio-features?ids=${trackIds}`,
            credentials,
            authData.user.id,
            supabase
          );

          if (audioFeaturesRes.audio_features && Array.isArray(audioFeaturesRes.audio_features)) {
            const validFeatures = audioFeaturesRes.audio_features.filter((f: any) => f !== null);
            rawAudioFeatures = validFeatures;

            if (validFeatures.length > 0) {
              const num = validFeatures.length;
              let acousticness = 0, danceability = 0, energy = 0, instrumentalness = 0;
              let liveness = 0, loudness = 0, speechiness = 0, tempo = 0, valence = 0;
              
              validFeatures.forEach((f: any) => {
                acousticness += f.acousticness || 0;
                danceability += f.danceability || 0;
                energy += f.energy || 0;
                instrumentalness += f.instrumentalness || 0;
                liveness += f.liveness || 0;
                loudness += f.loudness || 0;
                speechiness += f.speechiness || 0;
                tempo += f.tempo || 0;
                valence += f.valence || 0;
              });

              // Normalize tempo (~50-200 BPM) and loudness (~-60 to 0) to 0-1 range
              const avgTempo = Math.min(Math.max((tempo / num) / 200.0, 0), 1);
              const avgLoudness = Math.min(Math.max(((loudness / num) + 60) / 60.0, 0), 1);
              
              let popularitySum = 0;
              ((topTracksRes.items ?? []) as any[]).forEach((t: any) => {
                popularitySum += t.popularity || 50;
              });
              const avgPopularity = (popularitySum / (topTracksRes.items?.length || 1)) / 100.0;

              const embeddingArr = [
                acousticness / num,
                danceability / num,
                energy / num,
                instrumentalness / num,
                liveness / num,
                avgLoudness,
                speechiness / num,
                avgTempo,
                valence / num,
                avgPopularity
              ];
              embedding = `[${embeddingArr.join(',')}]`; // vector string format for pgvector
            }
          }
        } catch (e) {
          console.error("Failed to fetch audio features", e);
        }
      }

      // ── Listening Heatmap (/me/player/recently-played) ──────────────
      // Aggreghiamo gli ascolti recenti per giorno della settimana.
      // Spotify restituisce fino a 50 track con played_at timestamp.
      // Giorno 0 = Lun, ..., 6 = Dom (compatibile con il display Flutter).
      const dayLabels = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"];
      const dayCounts: number[] = [0, 0, 0, 0, 0, 0, 0];

      try {
        const recentlyPlayedRes = await spotifyGet(
          "/me/player/recently-played?limit=50",
          credentials,
          authData.user.id,
          supabase
        );

        const items = (recentlyPlayedRes.items ?? []) as any[];
        for (const item of items) {
          const playedAt = item?.played_at;
          if (!playedAt) continue;
          const date = new Date(playedAt);
          // getDay() returns 0=Sun...6=Sat; we remap to 0=Mon...6=Sun
          const jsDay = date.getDay(); // 0=Dom, 1=Lun, ... 6=Sab
          const remapped = jsDay === 0 ? 6 : jsDay - 1; // 0=Lun...6=Dom
          dayCounts[remapped]++;
        }
      } catch (e) {
        console.error("Failed to fetch recently-played for heatmap", e);
        // Fallback: all zeros — UI will show empty bars
      }

      const maxCount = Math.max(...dayCounts, 1); // avoid division by zero
      const listeningHeatmap = dayLabels.map((label, i) => ({
        day: label,
        value: Number((dayCounts[i] / maxCount).toFixed(4)),
      }));

      const payload = {
        user_id: authData.user.id,
        top_artists: topArtists,
        top_tracks: topTracks,
        top_genres: topGenres,
        audio_features: rawAudioFeatures,
        embedding: embedding,
        listening_heatmap: listeningHeatmap,
        last_synced_at: new Date().toISOString(),
      };

      const { data: saved, error: saveError } = await supabase.rpc("save_connected_music_profile", {
        p_user_id: authData.user.id,
        p_spotify_user_id: credentials.spotifyUserId,
        p_connected_at: credentials.connectedAt,
        p_profile: payload,
      });

      if (saveError?.code === "PT503") return spotifyUnavailableResponse();
      if (saveError?.code === "PT409") return new Response(JSON.stringify({ error: "spotify_not_connected" }), {
        status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
      if (saveError) throw saveError;

      return new Response(JSON.stringify(saved), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } catch (e) {
      if (e instanceof SpotifyRequestError && e.status === 503) return spotifyUnavailableResponse();
      if (e instanceof SpotifyRequestError && e.status === 409) return new Response(JSON.stringify({ error: "spotify_not_connected" }), {
        status: 409, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
      throw e;
    }
  } catch (e) {
    return new Response(JSON.stringify({
      error: "internal_error",
      message: e instanceof Error ? e.message : String(e),
    }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
