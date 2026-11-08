// Server-side Spotify Web API client for a connected Vibra user.
//
// Tokens never leave the backend: they are stored encrypted in
// public.spotify_connections and are refreshed here, proactively before
// expiry and reactively on 401. Rate limits (429) honour Retry-After with a
// bounded wait. A revoked grant (user removed Vibra from their Spotify
// account) is surfaced as SpotifyRevokedError so callers can disconnect.
import { requireEnv } from "./env.ts";
import { decryptToken, encryptToken } from "./token-crypto.ts";

export class SpotifyRequestError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

/** The refresh token is no longer valid: access was revoked or expired. */
export class SpotifyRevokedError extends SpotifyRequestError {
  constructor() {
    super(401, "spotify_access_revoked");
  }
}

export type ConnectionRow = {
  user_id: string;
  spotify_user_id: string;
  connected_at: string;
  access_token_ciphertext: string;
  refresh_token_ciphertext: string | null;
  token_expires_at: string;
};

type Sleep = (ms: number) => Promise<void>;
const defaultSleep: Sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/** Refresh this long before expiry so a sync never starts on a dying token. */
export const REFRESH_MARGIN_MS = 5 * 60 * 1000;
/** Longest single Retry-After we are willing to wait inside one request. */
export const MAX_RETRY_AFTER_MS = 30_000;
const MAX_RATE_LIMIT_RETRIES = 2;

export function retryAfterMs(response: Response): number {
  const header = response.headers.get("Retry-After");
  const seconds = header === null ? NaN : Number(header);
  // Spotify sends whole seconds; fall back to a short pause if absent.
  return Number.isFinite(seconds) && seconds >= 0 ? seconds * 1000 : 1000;
}

/**
 * Refresh grant for tokens issued through Authorization Code + PKCE:
 * client_id in the body, no client secret (Spotify PKCE refresh contract).
 */
export async function refreshAccessToken(
  refreshToken: string,
  request: typeof fetch = fetch,
): Promise<{ access_token: string; refresh_token?: string; expires_in?: number; scope?: string }> {
  const response = await request("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: refreshToken,
      client_id: requireEnv("SPOTIFY_CLIENT_ID"),
    }),
  });
  const json = await response.json().catch(() => ({}));
  if (response.status === 400 && json?.error === "invalid_grant") {
    throw new SpotifyRevokedError();
  }
  if (!response.ok || typeof json?.access_token !== "string") {
    throw new SpotifyRequestError(response.status, "spotify_refresh_failed");
  }
  return json;
}

/**
 * Persists a refreshed token pair only if the connection is still the same
 * one (disconnect or reconnect can win the race while Spotify answers).
 */
export type SaveRefreshed = (tokens: {
  accessTokenCiphertext: string;
  refreshTokenCiphertext: string | null;
  expiresAt: string;
}) => Promise<boolean>;

export class SpotifyClient {
  private accessToken = "";
  private refreshToken: string | null = null;
  private expiresAt = 0;

  private constructor(
    private readonly save: SaveRefreshed,
    private readonly request: typeof fetch,
    private readonly sleep: Sleep,
    private readonly now: () => number,
  ) {}

  static async fromConnection(
    row: ConnectionRow,
    save: SaveRefreshed,
    options: { request?: typeof fetch; sleep?: Sleep; now?: () => number } = {},
  ): Promise<SpotifyClient> {
    const client = new SpotifyClient(
      save,
      options.request ?? fetch,
      options.sleep ?? defaultSleep,
      options.now ?? Date.now,
    );
    client.accessToken = await decryptToken(row.access_token_ciphertext);
    client.refreshToken = row.refresh_token_ciphertext
      ? await decryptToken(row.refresh_token_ciphertext)
      : null;
    client.expiresAt = Date.parse(row.token_expires_at) || 0;
    return client;
  }

  /** Refresh now. Throws SpotifyRevokedError when the grant is gone. */
  async refresh(): Promise<void> {
    if (!this.refreshToken) throw new SpotifyRevokedError();
    const fresh = await refreshAccessToken(this.refreshToken, this.request);
    this.accessToken = fresh.access_token;
    if (fresh.refresh_token) this.refreshToken = fresh.refresh_token;
    this.expiresAt = this.now() + (fresh.expires_in ?? 3600) * 1000;
    const saved = await this.save({
      accessTokenCiphertext: await encryptToken(this.accessToken),
      refreshTokenCiphertext: fresh.refresh_token ? await encryptToken(fresh.refresh_token) : null,
      expiresAt: new Date(this.expiresAt).toISOString(),
    });
    if (!saved) throw new SpotifyRequestError(409, "spotify_connection_changed");
  }

  get tokenExpiresAt(): number {
    return this.expiresAt;
  }

  /** GET https://api.spotify.com/v1{path} with refresh, retry and backoff. */
  async get(path: string): Promise<any> {
    if (this.expiresAt - this.now() < REFRESH_MARGIN_MS) await this.refresh();
    let refreshed = false, rateLimited = 0;
    while (true) {
      const response = await this.request(`https://api.spotify.com/v1${path}`, {
        headers: { Authorization: `Bearer ${this.accessToken}`, Accept: "application/json" },
        signal: AbortSignal.timeout(15000),
      });
      if (response.status === 401 && !refreshed) {
        await response.body?.cancel();
        refreshed = true;
        await this.refresh();
        continue;
      }
      if (response.status === 429 && rateLimited < MAX_RATE_LIMIT_RETRIES) {
        const wait = retryAfterMs(response);
        await response.body?.cancel();
        if (wait > MAX_RETRY_AFTER_MS) throw new SpotifyRequestError(429, "spotify_rate_limited");
        rateLimited++;
        await this.sleep(wait);
        continue;
      }
      if (!response.ok) {
        await response.body?.cancel();
        if (response.status === 401) throw new SpotifyRevokedError();
        throw new SpotifyRequestError(response.status, `spotify_get_failed_${response.status}`);
      }
      return await response.json();
    }
  }
}
