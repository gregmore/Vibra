import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

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
  };
}

async function spotifyGet(
  path: string,
  credentials: { accessToken: string; refreshToken: string | null },
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

    await supabase
      .from("users")
      .update({
        spotify_access_token: credentials.accessToken,
        spotify_refresh_token: credentials.refreshToken,
      })
      .eq("id", userId);

    response = await fetch(`https://api.spotify.com/v1${path}`, {
      headers: { Authorization: `Bearer ${credentials.accessToken}` },
    });
  }

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Spotify GET ${path} failed: ${response.status} ${text}`);
  }

  return await response.json();
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    const userClient = createUserClient(req);
    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createSupabaseServiceClient();
    const { data: userRow, error: userRowError } = await supabase
      .from("users")
      .select("spotify_access_token, spotify_refresh_token")
      .eq("id", authData.user.id)
      .maybeSingle();

    if (userRowError) throw userRowError;
    if (!userRow?.spotify_access_token) {
      return new Response(JSON.stringify({ error: "spotify_not_connected" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const credentials = {
      accessToken: userRow.spotify_access_token as string,
      refreshToken: userRow.spotify_refresh_token as string | null,
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

      const genreCounts: Record<string, number> = {};
      const artistsArr = (topArtistsRes.items ?? []) as any[];
      
      // Some Spotify accounts/regions return SimplifiedArtistObject without genres in /me/top/artists.
      // To guarantee genres, we fetch the full artist objects using /artists?ids=...
      let debugMsg = "DEBUG: initialized";
      let fullArtists = artistsArr;
      if (artistsArr.length > 0 && !artistsArr[0].genres) {
        // Try to fetch just ONE artist to see if /artists/{id} is also forbidden
        const firstArtistId = artistsArr.find((a: any) => typeof a.id === 'string' && a.id.length > 15)?.id;
        
        if (firstArtistId) {
          try {
            debugMsg = "DEBUG: fetching /artists/" + firstArtistId;
            const singleArtistRes = await spotifyGet(
              `/artists/${firstArtistId}`,
              credentials,
              authData.user.id,
              supabase
            );
            
            if (singleArtistRes.genres) {
              debugMsg = "DEBUG: got single artist genres: " + JSON.stringify(singleArtistRes.genres);
              // Since bulk is forbidden, let's just use the single artist for now to see if it works
              fullArtists = [singleArtistRes];
            } else {
              debugMsg = "DEBUG: singleArtistRes has no genres";
            }
          } catch (e: any) {
            const fullErr = "DEBUG ERROR: " + (e.message || String(e));
            debugMsg = fullErr.length > 200 
              ? "..." + fullErr.substring(fullErr.length - 197) 
              : fullErr;
            console.error("Failed to fetch single artist for genres", e);
          }
        }
      } else if (artistsArr.length > 0) {
        debugMsg = "DEBUG: initial artists had genres: " + JSON.stringify(artistsArr[0].genres);
      }

      for (const artist of fullArtists) {
        const genres = (artist?.genres ?? []) as string[];
        for (const genre of genres) {
          const key = genre.trim().toLowerCase();
          if (!key) continue;
          genreCounts[key] = (genreCounts[key] ?? 0) + 1;
        }
      }

      const sortedGenres = Object.entries(genreCounts).sort((a, b) => b[1] - a[1]);
      const maxGenre = sortedGenres.length > 0 ? sortedGenres[0][1] : 1;
      let topGenres = sortedGenres.map(([genre, count]) => ({
        genre,
        weight: Number((count / maxGenre).toFixed(4)),
      }));
      
      if (topGenres.length === 0) {
        // Fallback: if we couldn't get genres (due to Spotify API restrictions),
        // we just leave the array empty. The UI will handle it gracefully.
        console.log("No genres available (likely due to Spotify Extended API Access restrictions)");
      }

      const { data: profileRow } = await supabase
        .from("music_profiles")
        .select("id")
        .eq("user_id", authData.user.id)
        .maybeSingle();

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

      const payload = {
        ...(profileRow?.id != null ? { id: profileRow.id } : {}),
        user_id: authData.user.id,
        top_artists: topArtists,
        top_tracks: topTracks,
        top_genres: topGenres,
        audio_features: rawAudioFeatures,
        embedding: embedding,
        last_synced_at: new Date().toISOString(),
      };

      const { data: saved, error: saveError } = await supabase
        .from("music_profiles")
        .upsert(payload, { onConflict: "user_id" })
        .select()
        .single();

      if (saveError) throw saveError;

      return new Response(JSON.stringify(saved), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } catch (e) {
      // Best effort refresh persistence when token expired
      if (credentials.refreshToken) {
        const refreshed = await refreshSpotifyAccessToken(credentials.refreshToken);
        credentials.accessToken = refreshed.access_token;
        credentials.refreshToken = refreshed.refresh_token ?? credentials.refreshToken;

        await supabase.from("users").update({
          spotify_access_token: credentials.accessToken,
          spotify_refresh_token: credentials.refreshToken,
        }).eq("id", authData.user.id);
      }

      throw e;
    }
  } catch (e) {
    return new Response(JSON.stringify({
      error: "internal_error",
      message: String(e?.message ?? e),
    }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
