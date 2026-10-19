import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { requireEnv } from "../_shared/env.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

// Auth deletion cascades from auth.users to every user-owned row.  Doing this
// with the admin client also revokes every refresh token/session server-side.
Deno.serve(async (req) => {
  const rejected = await rejectRevokedSession(req, "delete-account");
  if (rejected) return rejected;
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
    auth: { persistSession: false }, global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: { user }, error } = await userClient.auth.getUser();
  if (error || !user) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: corsHeaders });
  const admin = createSupabaseServiceClient();
  // Storage deletion is idempotent. Keep the Auth account available for a
  // retry if any batch fails; never report erasure before all objects are gone.
  const fail = () => new Response(JSON.stringify({ error: "account_erasure_failed" }), { status: 500, headers: corsHeaders });
  const { error: beginError } = await admin.rpc("begin_account_erasure", { p_user_id: user.id });
  if (beginError) return fail();
  let storageCleared = false;
  for (let batch = 0; batch < 100; batch++) {
    const { data: objects, error: listError } = await admin.rpc("list_account_storage_objects", { p_user_id: user.id });
    if (listError) return fail();
    if (!objects?.length) { storageCleared = true; break; }
    const buckets = new Map<string, string[]>();
    for (const object of objects as { bucket_id: string; name: string }[]) {
      const paths = buckets.get(object.bucket_id) ?? [];
      paths.push(object.name); buckets.set(object.bucket_id, paths);
    }
    for (const [bucket, paths] of buckets) {
      const { error: storageError } = await admin.storage.from(bucket).remove(paths);
      if (storageError) return fail();
    }
  }
  if (!storageCleared) return fail();
  // Hard delete removes Auth sessions and cascades through public.users. The
  // profile's erasure trigger detaches both sides of retained conversations.
  const { error: deleteError } = await admin.auth.admin.deleteUser(user.id, false);
  if (deleteError) return fail();
  return new Response(JSON.stringify({ deleted: true }), { headers: { ...corsHeaders, "Content-Type": "application/json" } });
});
