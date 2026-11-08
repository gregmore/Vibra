import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { requireEnv } from "../_shared/env.ts";
import { cleanHistory } from "../_shared/ai/answer.ts";
import { assistantAvailable, getAssistantProvider } from "../_shared/ai/provider.ts";
import { supabaseAssistantData } from "../_shared/ai/supabase_data.ts";

// VIBRA AI (docs/vibra-ai.md), optional.
//   { action: "status" }            → { available, consent }
//   { action: "ask", messages: [...] } → { answer, verified, ideas, status }
// Requires the user's explicit consent. Conversations are not stored and
// prompts are never logged.

const headers = { ...corsHeaders, "Content-Type": "application/json", "Cache-Control": "no-store" };
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers });

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;
  if (req.method !== "POST") return reply(405, { error: "method_not_allowed" });
  const rejected = await rejectRevokedSession(req, "vibra-ai");
  if (rejected) return rejected;

  try {
    const userClient = createClient(requireEnv("SUPABASE_URL"), requireEnv("SUPABASE_ANON_KEY"), {
      auth: { persistSession: false, autoRefreshToken: false },
      global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
    });
    const { data: auth, error: authError } = await userClient.auth.getUser();
    if (authError || !auth.user) return reply(401, { error: "Unauthorized" });

    let body: Record<string, unknown> = {};
    try {
      body = await req.json();
    } catch {
      return reply(400, { error: "invalid_request" });
    }

    if (body.action === "status") {
      const { data: prefs } = await userClient.from("privacy_preferences")
        .select("ai_assistant").eq("user_id", auth.user.id).maybeSingle();
      return reply(200, { available: await assistantAvailable(), consent: prefs?.ai_assistant === true });
    }

    if (body.action === "ask") {
      const provider = await getAssistantProvider();
      if (!provider) return reply(503, { error: "assistant_unavailable" });
      const history = cleanHistory(body.messages);
      if (!history) return reply(400, { error: "invalid_messages" });
      const { error: gate } = await userClient.rpc("begin_ai_assistant_request");
      if (gate) {
        const message = String(gate.message ?? "");
        if (message.includes("ai_consent_required")) return reply(403, { error: "consent_required" });
        if (gate.code === "PT429" || message.includes("limit")) return reply(429, { error: "rate_limited" });
        throw gate;
      }
      const answer = await provider.ask(history, supabaseAssistantData(userClient, auth.user.id));
      return reply(200, { ...answer, provider: provider.name, generated: true });
    }

    return reply(400, { error: "invalid_action" });
  } catch (e) {
    // Never log the question or the answer.
    console.error("vibra-ai failed", e instanceof Error ? e.name : "error");
    return reply(502, { error: "assistant_failed" });
  }
});
