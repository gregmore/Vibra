import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";
import { optionalEnv, requireEnv } from "../_shared/env.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { decryptToken, encryptToken } from "../_shared/token-crypto.ts";

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
  const rejected = await rejectRevokedSession(req, "spotify-token-exchange");
  if (rejected) return rejected;
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
    if (body.action !== "exchange" && body.action !== "refresh") {
      return new Response(JSON.stringify({ error: "invalid_action" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
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
    const redirectUri = optionalEnv("SPOTIFY_REDIRECT_URI") ?? "com.vibra.app://callback";
    if (body.redirect_uri !== undefined && body.redirect_uri !== redirectUri) {
      return new Response(JSON.stringify({ error: "invalid_redirect_uri" }), {
        status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

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
      const { data: connection } = await appClient
        .from("spotify_connections")
        .select("refresh_token_ciphertext")
        .eq("user_id", authData.user.id)
        .maybeSingle();
      if (!connection?.refresh_token_ciphertext) {
        return new Response(JSON.stringify({ error: "refresh_token_missing" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      const form = new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: await decryptToken(connection.refresh_token_ciphertext),
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

    const { data: currentProfile, error: currentProfileError } = await appClient
      .from("users")
      .select("id, username, display_name, avatar_url, spotify_id")
      .eq("id", authData.user.id)
      .maybeSingle();

    if (currentProfileError) {
      throw new Error(`Failed to load current profile: ${currentProfileError.message}`);
    }

    // A refresh token must only be used for the Spotify account already linked
    // to this Vibra account. Switching accounts is intentionally possible, but
    // it must go through a fresh OAuth exchange with user consent.
    if (
      body.action === "refresh" &&
      currentProfile?.spotify_id &&
      currentProfile.spotify_id !== spotifyId
    ) {
      return new Response(JSON.stringify({
        error: "spotify_refresh_account_mismatch",
        message: "Il token di aggiornamento non appartiene all'account Spotify collegato a Vibra.",
      }), {
        status: 409,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

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

    // Keep the profile choices made in Vibra (username, name and avatar) on
    // subsequent Spotify connections. Tokens are persisted server-side too:
    // sync-music-profile runs on the backend and must never depend only on a
    // token stored on the device.
    const profilePayload = {
      id: authData.user.id,
      email: authData.user.email ?? "",
      username: currentProfile?.username ??
          (authData.user.user_metadata["username"] as string | undefined) ??
          (authData.user.email?.split("@")[0] ?? `user_${authData.user.id.substring(0, 8)}`),
      display_name: currentProfile?.display_name ??
          (authData.user.user_metadata["display_name"] as string | undefined) ??
          spotifyMe["display_name"] ??
          authData.user.email?.split("@")[0],
      avatar_url: currentProfile?.avatar_url ??
          (Array.isArray(spotifyMe["images"]) && spotifyMe["images"].length > 0
        ? (spotifyMe["images"][0]["url"] as string | undefined)
        : null),
      spotify_id: spotifyId,
    };

    const { error: upsertError } = await appClient
      .from("users")
      .upsert(profilePayload, { onConflict: "id" });

    if (upsertError) {
      if (upsertError.code === "23505") {
        return new Response(JSON.stringify({
          error: "spotify_account_already_linked",
          message: "Questo account Spotify è già collegato a un altro profilo Vibra.",
        }), {
          status: 409,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      throw new Error(`Failed to persist Spotify connection: ${upsertError.message}`);
    }

    const { data: existingConnection, error: connectionError } = await appClient
      .from("spotify_connections")
      .select("refresh_token_ciphertext")
      .eq("user_id", authData.user.id)
      .maybeSingle();
    if (connectionError) throw new Error(`Failed to load Spotify connection: ${connectionError.message}`);
    const { error: saveConnectionError } = await appClient
      .from("spotify_connections")
      .upsert({
        user_id: authData.user.id,
        spotify_user_id: spotifyId,
        access_token_ciphertext: await encryptToken(accessToken),
        refresh_token_ciphertext: refreshToken
          ? await encryptToken(refreshToken)
          : existingConnection?.refresh_token_ciphertext ?? null,
        token_expires_at: new Date(Date.now() + expiresIn * 1000).toISOString(),
      }, { onConflict: "user_id" });
    if (saveConnectionError) throw new Error(`Failed to persist encrypted Spotify connection: ${saveConnectionError.message}`);

    // Completing the explicitly initiated OAuth connection records consent for
    // the optional matching use described in the connect screen.
    const { error: preferenceError } = await appClient.from("privacy_preferences").upsert({
      user_id: authData.user.id,
      spotify_matching: true,
      policy_version: "2026-08-27",
      updated_at: new Date().toISOString(),
    }, { onConflict: "user_id" });
    if (preferenceError) throw new Error(`Failed to record Spotify preference: ${preferenceError.message}`);


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
      message: String(e instanceof Error ? e.message : e),
    }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
