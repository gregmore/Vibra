import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { clamp } from "../_shared/geo.ts";

type CalculateMatchRequest = {
  user_id?: string; // If not provided, might be a batch job
};

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method.toUpperCase() !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json().catch(() => ({})) as CalculateMatchRequest;
    
    // In a real production setup, we might extract the user_id from the Auth header if not provided in body
    const supabase = createSupabaseServiceClient();

    let targetUserId = body.user_id;

    if (!targetUserId) {
      // If no user_id, let's try to get it from auth
      const authHeader = req.headers.get("Authorization");
      if (authHeader) {
         const { data: { user } } = await supabase.auth.getUser(authHeader.replace("Bearer ", ""));
         if (user) targetUserId = user.id;
      }
    }

    if (!targetUserId) {
      return new Response(
        JSON.stringify({ error: "user_id is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Fetch user profile and embedding
    const { data: userProfile, error: profileErr } = await supabase
      .from("music_profiles")
      .select("user_id, embedding, top_artists, top_genres")
      .eq("user_id", targetUserId)
      .maybeSingle();
      
    if (profileErr) throw profileErr;
    if (!userProfile) {
      return new Response(JSON.stringify({ error: "music_profile_missing" }), { status: 404, headers: corsHeaders });
    }

    // If no embedding, fallback to the old Jaccard logic or abort
    if (!userProfile.embedding) {
      return new Response(
        JSON.stringify({ error: "embedding_missing", message: "Utente non ha ancora le audio features." }),
        { status: 400, headers: corsHeaders }
      );
    }
    
    const { data: matches, error: matchErr } = await supabase.rpc("find_compatible_users", {
      p_user_id: targetUserId,
      p_embedding: userProfile.embedding,
      p_limit: 50
    });

    if (matchErr) throw matchErr;

    // 2. Hybrid Scoring in JS (can also be done in SQL, but JS is easier to tweak)
    // Here we can fetch config from algorithm_config
    const { data: configRows } = await supabase.from("algorithm_config").select("*").eq("active", true).limit(1);
    const config = configRows?.[0] ?? { content_weight: 0.6, collab_weight: 0.1, geo_weight: 0.2, social_weight: 0.1, serendipity_factor: 0.15 };

    const upserts = [];
    
    const myArtists = new Set((userProfile.top_artists ?? []).map((a: any) => a.id).filter(Boolean));

    for (const match of (matches || [])) {
      if (match.user_id === targetUserId) continue; // Skip self
      
      // pgvector returns cosine distance (0 to 2) usually, similarity is 1 - distance
      // Match distance from RPC: match.distance
      const vectorSimilarity = Math.max(0, 1 - (match.distance || 0));
      
      // Calculate shared artists to boost
      const theirArtists = match.top_artists || [];
      let sharedArtists = 0;
      for (const a of theirArtists) {
        if (myArtists.has(a.id)) sharedArtists++;
      }
      
      const artistBoost = Math.min(sharedArtists * 5, 30) / 100.0; // Up to 30% boost for shared artists
      
      // Calculate final score
      // Simulating a geo/social hybrid score for now
      let finalScore = (vectorSimilarity * config.content_weight) + artistBoost;
      
      // Add serendipity (random variance)
      if (Math.random() < config.serendipity_factor) {
        finalScore += (Math.random() * 0.2); // +0 to +20%
      }
      
      const compatibility = clamp(finalScore * 100, 0, 100);

      const [a, b] = targetUserId < match.user_id
        ? [targetUserId, match.user_id]
        : [match.user_id, targetUserId];

      upserts.push({
        user_id_a: a,
        user_id_b: b,
        compatibility: Math.round(compatibility),
        shared_artists: sharedArtists,
        shared_genres: 0 // Simplification
      });
    }

    if (upserts.length > 0) {
      const { error: upsertError } = await supabase
        .from("user_matches")
        .upsert(upserts, { onConflict: "user_id_a,user_id_b" });

      if (upsertError) throw upsertError;
    }

    return new Response(
      JSON.stringify({
        success: true,
        matches_found: upserts.length,
        message: "Match calcolati con pgvector!"
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({
        error: "internal_error",
        message: String(e?.message ?? e),
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
