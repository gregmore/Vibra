import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { requireEnv } from "../_shared/env.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

Deno.serve(async (req) => {
  const rejected = await rejectRevokedSession(req, "spotify-disconnect");
  if (rejected) return rejected;
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
    auth: { persistSession: false }, global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: { user } } = await userClient.auth.getUser();
  if (!user) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
  const admin = createSupabaseServiceClient();
  const { error } = await admin.from("spotify_connections").delete().eq("user_id", user.id);
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders });
  await admin.from("users").update({ spotify_id: null }).eq("id", user.id);
  await admin.from("music_profiles").delete().eq("user_id", user.id);
  await admin.from("privacy_preferences").update({ spotify_matching: false, updated_at: new Date().toISOString() }).eq("user_id", user.id);
  return new Response(JSON.stringify({ success: true }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
});
