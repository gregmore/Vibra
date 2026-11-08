// VIBRA AI data access (docs/vibra-ai.md). Everything is read with the
// caller's own session, so RLS applies: only their profile, events and
// communities visible to them. Spotify is read with the app's
// client-credentials token: a user's Spotify tokens are never read here.
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { getSpotifyAppAccessToken } from "../spotify_app_token.ts";
import { spotifyApi } from "../spotify_tracks.ts";
import type { AssistantData, CommunityRow, EventRow, MyProfile } from "./types.ts";

const like = (v: string) => `%${v.replace(/[%_,()]/g, " ").trim()}%`;

export function supabaseAssistantData(userClient: SupabaseClient, userId: string): AssistantData {
  return {
    async myProfile(): Promise<MyProfile> {
      const [{ data: dna }, { data: picked }, { data: profile }] = await Promise.all([
        userClient.rpc("get_musical_dna", { p_user_id: userId }),
        userClient.from("user_genre_preferences").select("genre_key").eq("user_id", userId),
        userClient.from("music_profiles").select("top_artists").eq("user_id", userId).maybeSingle(),
      ]);
      // deno-lint-ignore no-explicit-any
      const d = (dna as any)?.dna ?? {};
      // deno-lint-ignore no-explicit-any
      const list = (v: any) => (Array.isArray(v) ? v : []);
      const families = list(d.families).slice(0, 8)
        .map((f: { key?: string; percent?: number }) => ({ key: String(f.key ?? ""), percent: Math.round(Number(f.percent ?? 0)) }))
        .filter((f: { key: string }) => f.key);
      const subgenres = list(d.subgenres).slice(0, 12)
        .map((s: { key?: string; percent?: number }) => ({ key: String(s.key ?? ""), percent: Math.round(Number(s.percent ?? 0)) }))
        .filter((s: { key: string }) => s.key);
      const artistNames = [
        ...list(d.artists).map((a: { name?: string }) => a?.name),
        // deno-lint-ignore no-explicit-any
        ...list((profile as any)?.top_artists).map((a: { name?: string } | string) => typeof a === "string" ? a : a?.name),
      ].filter((n): n is string => typeof n === "string" && !!n.trim());
      const top_artists = [...new Set(artistNames.map((n) => n.trim().slice(0, 100)))].slice(0, 15);
      const picked_genres = list(picked).map((p: { genre_key?: string }) => p.genre_key)
        .filter((k): k is string => typeof k === "string" && !!k).slice(0, 20);
      return {
        families, subgenres, top_artists, picked_genres,
        has_data: families.length > 0 || top_artists.length > 0 || picked_genres.length > 0,
      };
    },

    async spotify(path: string) {
      return spotifyApi(path, await getSpotifyAppAccessToken());
    },

    async upcomingEvents({ artist, city }): Promise<EventRow[]> {
      let q = userClient.from("events")
        .select("id, name, artist_name, venue_name, city, country, event_date, ticket_url, image_url, genres, status")
        .gte("event_date", new Date().toISOString())
        .neq("status", "canceled")
        .order("event_date", { ascending: true })
        .limit(artist ? 30 : 300);
      if (artist) q = q.or(`artist_name.ilike.${like(artist)},name.ilike.${like(artist)}`);
      if (city) q = q.ilike("city", like(city));
      const { data, error } = await q;
      if (error) throw error;
      return (data ?? []) as EventRow[];
    },

    async communities(): Promise<CommunityRow[]> {
      const { data, error } = await userClient.rpc("get_communities", { p_search: null, p_limit: 300 });
      if (error) throw error;
      return (data ?? []) as CommunityRow[];
    },
  };
}
