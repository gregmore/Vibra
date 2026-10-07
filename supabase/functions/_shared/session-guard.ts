import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders } from "./cors.ts";
import { requireEnv } from "./env.ts";

// Signature verification alone does not invalidate a signed JWT after logout.
// Run the session check with the caller's JWT, never the service role.
export async function rejectRevokedSession(req: Request, action: string): Promise<Response | null> {
  if (req.method === "OPTIONS") return null;
  const authorization = req.headers.get("Authorization") ?? "";
  if (authorization === `Bearer ${requireEnv("SUPABASE_SERVICE_ROLE_KEY")}`) return null;
  const client = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: authorization } },
  });
  try {
    const { data, error } = await client.auth.getUser();
    if (!error && data.user) {
      const { data: active, error: sessionError } = await client.rpc("has_active_session");
      if (!sessionError && active === true) {
        const { error: limitError } = await client.rpc("consume_action_limit", { p_action: action });
        if (!limitError) return null;
        if (limitError.code === "PT429") return new Response(JSON.stringify({ error: "rate_limit_exceeded" }), {
          status: 429, headers: { ...corsHeaders, "Content-Type": "application/json", "Retry-After": "60" },
        });
      }
    }
  } catch { /* Fail closed if Auth or the session check is unavailable. */ }
  return new Response(JSON.stringify({ error: "Unauthorized" }), {
    status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
