import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { optionalEnv, requireEnv } from "../_shared/env.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

type ExchangeBody = {
  action: "exchange" | "refresh";
  code?: string;
  code_verifier?: string;
  redirect_uri?: string;
};

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

async function fetchSpotifyProfile(accessToken: string) {
  const response = await fetch("https://api.spotify.com/v1/me", {
    headers: { 
      Authorization: `Bearer ${accessToken}`,
      "User-Agent": "VibraApp/1.0",
      "Accept": "application/json"
    },
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`Spotify /me failed: ${response.status} - ${errText}`);
  }

  return await response.json();
}

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

    const body = (await req.json()) as ExchangeBody;
    const userClient = createUserClient(req);
    const { data: authData, error: userError } = await userClient.auth.getUser();
    if (userError || !authData.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const appClient = createSupabaseServiceClient();
    const spotifyClientId = requireEnv("SPOTIFY_CLIENT_ID");
    const spotifyClientSecret = requireEnv("SPOTIFY_CLIENT_SECRET");
    const redirectUri = body.redirect_uri ?? optionalEnv("SPOTIFY_REDIRECT_URI") ?? "com.vibra.app://callback";

    let spotifyResponse: Response;
    if (body.action === "exchange") {
      if (!body.code || !body.code_verifier) {
        return new Response(JSON.stringify({ error: "code and code_verifier are required" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const form = new URLSearchParams({
        grant_type: "authorization_code",
        code: body.code,
        redirect_uri: redirectUri,
        client_id: spotifyClientId,
        code_verifier: body.code_verifier,
      });

      spotifyResponse = await fetch("https://accounts.spotify.com/api/token", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: form,
      });
    } else {
      const refreshToken = (body as any).refresh_token;

      if (!refreshToken) {
        return new Response(JSON.stringify({ error: "refresh_token_missing" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const form = new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: refreshToken,
      });

      const basic = btoa(`${spotifyClientId}:${spotifyClientSecret}`);
      spotifyResponse = await fetch("https://accounts.spotify.com/api/token", {
        method: "POST",
        headers: {
          Authorization: `Basic ${basic}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: form,
      });
    }

    const tokenJson = await spotifyResponse.json();
    if (!spotifyResponse.ok) {
      return new Response(JSON.stringify({
        error: "spotify_token_exchange_failed",
        details: tokenJson,
      }), {
        status: spotifyResponse.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const accessToken = tokenJson.access_token as string;
    const refreshToken = (tokenJson.refresh_token as string | undefined) ?? null;
    const expiresIn = Number(tokenJson.expires_in ?? 3600);
    const scope = tokenJson.scope as string | undefined;

    const spotifyMe = await fetchSpotifyProfile(accessToken);

    const spotifyId = spotifyMe["id"];

    if (spotifyId) {
      const { data: existingUsers, error: checkError } = await appClient
        .from("users")
        .select("id")
        .eq("spotify_id", spotifyId)
        .neq("id", authData.user.id);

      if (checkError) {
        throw new Error(`Failed to check existing spotify_id: ${checkError.message}`);
      }

      if (existingUsers && existingUsers.length > 0) {
        return new Response(JSON.stringify({
          error: "spotify_account_already_linked",
          message: "Questo account Spotify è già collegato a un altro profilo Vibra.",
        }), {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
    }

    await appClient.from("users").upsert({
      id: authData.user.id,
      email: authData.user.email ?? "",
      username: (authData.user.user_metadata["username"] as string | undefined) ??
          (authData.user.email?.split("@")[0] ?? `user_${authData.user.id.substring(0, 8)}`),
      display_name: (authData.user.user_metadata["display_name"] as string | undefined) ??
          spotifyMe["display_name"] ??
          authData.user.email?.split("@")[0],
      avatar_url: Array.isArray(spotifyMe["images"]) && spotifyMe["images"].length > 0
        ? (spotifyMe["images"][0]["url"] as string | undefined)
        : null,
      spotify_id: spotifyId,
    }, { onConflict: "id" });


    return new Response(JSON.stringify({
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: expiresIn,
      scope: scope,
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
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
