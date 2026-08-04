import { corsHeaders } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { requireEnv } from "../_shared/env.ts";

async function getSpotifyAppToken() {
  const clientId = requireEnv("SPOTIFY_CLIENT_ID");
  const clientSecret = requireEnv("SPOTIFY_CLIENT_SECRET");
  const basic = btoa(`${clientId}:${clientSecret}`);

  const res = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${basic}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });

  if (!res.ok) {
    throw new Error(`Failed to get app token: ${await res.text()}`);
  }

  const data = await res.json();
  return data.access_token;
}

Deno.serve(async (req) => {
  try {
    const supabase = createSupabaseServiceClient();

    // Find up to 50 events that don't have an embedding yet and have a spotify artist ID
    const { data: events, error } = await supabase
      .from("events")
      .select("id, artist_spotify_id")
      .is("embedding", null)
      .not("artist_spotify_id", "is", null)
      .neq("artist_spotify_id", "")
      .limit(50);

    if (error) throw error;

    if (!events || events.length === 0) {
      return new Response(JSON.stringify({ message: "No events to process" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const token = await getSpotifyAppToken();
    let processed = 0;

    for (const event of events) {
      if (!event.artist_spotify_id) continue;
      
      // Get artist's top tracks
      const topRes = await fetch(`https://api.spotify.com/v1/artists/${event.artist_spotify_id}/top-tracks?market=IT`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      if (!topRes.ok) continue;
      const topData = await topRes.json();
      
      const trackIds = (topData.tracks || []).slice(0, 10).map((t: any) => t.id).join(",");
      if (!trackIds) continue;
      
      // Get audio features for these tracks
      const audioRes = await fetch(`https://api.spotify.com/v1/audio-features?ids=${trackIds}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      
      if (!audioRes.ok) continue;
      const audioData = await audioRes.json();
      
      const validFeatures = (audioData.audio_features || []).filter((f: any) => f !== null);
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

        const avgTempo = Math.min(Math.max((tempo / num) / 200.0, 0), 1);
        const avgLoudness = Math.min(Math.max(((loudness / num) + 60) / 60.0, 0), 1);
        
        let popularitySum = 0;
        (topData.tracks || []).slice(0, 10).forEach((t: any) => {
          popularitySum += t.popularity || 50;
        });
        const avgPopularity = (popularitySum / Math.max(1, (topData.tracks?.length || 1))) / 100.0;

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
        
        const embedding = `[${embeddingArr.join(',')}]`;
        
        await supabase.from("events").update({ embedding }).eq("id", event.id);
        processed++;
      }
    }

    return new Response(JSON.stringify({ message: `Processed ${processed} events` }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e: any) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
