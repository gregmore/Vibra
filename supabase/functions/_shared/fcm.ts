import { optionalEnv } from "./env.ts";

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};
type AccessToken = { value: string; expiresAt: number };
let cachedToken: AccessToken | undefined;
let cachedCredentials: string | undefined;
let pendingToken: Promise<AccessToken> | undefined;
const TOKEN_URL = "https://oauth2.googleapis.com/token";
const FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

function base64url(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes))
    .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}

async function authorize(account: ServiceAccount): Promise<AccessToken> {
  const now = Math.floor(Date.now() / 1000);
  const encode = (value: unknown) => base64url(new TextEncoder().encode(JSON.stringify(value)));
  const unsigned = `${encode({ alg: "RS256", typ: "JWT" })}.${encode({
    iss: account.client_email, scope: FCM_SCOPE, aud: TOKEN_URL,
    iat: now, exp: now + 3600,
  })}`;
  const pem = account.private_key.replace(/-----[^-]+-----|\s/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8", Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(unsigned),
  );
  const response = await fetch(TOKEN_URL, {
    method: "POST", signal: AbortSignal.timeout(10000),
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${base64url(new Uint8Array(signature))}`,
    }),
  });
  if (!response.ok) throw new Error("FCM authorization failed");
  const result = await response.json();
  if (typeof result.access_token !== "string" || !result.access_token ||
      typeof result.expires_in !== "number" || result.expires_in <= 0) {
    throw new Error("Invalid FCM authorization response");
  }
  return { value: result.access_token, expiresAt: Date.now() + result.expires_in * 1000 };
}

async function token(account: ServiceAccount): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60000) return cachedToken.value;
  if (!pendingToken) pendingToken = authorize(account);
  try {
    cachedToken = await pendingToken;
    return cachedToken.value;
  } finally {
    pendingToken = undefined;
  }
}

/** Send via FCM HTTP v1. Credentials stay in Supabase secrets, never the app. */
export async function sendFcm(
  fcmToken: string, title: string, body: string, data?: Record<string, string>,
): Promise<boolean> {
  const credentials = optionalEnv("FCM_SERVICE_ACCOUNT_JSON") ??
    optionalEnv("FIREBASE_SERVICE_ACCOUNT_JSON");
  if (!credentials || !fcmToken) return false;
  try {
    const account = JSON.parse(credentials) as ServiceAccount;
    if (!account.client_email || !account.private_key ||
        !/^[a-z][a-z0-9-]{4,61}[a-z0-9]$/.test(account.project_id ?? "")) {
      throw new Error("Invalid FCM service account configuration");
    }
    if (cachedCredentials !== credentials) {
      cachedCredentials = credentials;
      cachedToken = undefined;
      pendingToken = undefined;
    }
    const url = `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`;
    for (let attempt = 0; attempt < 2; attempt++) {
      const accessToken = await token(account);
      const response = await fetch(url, {
        method: "POST", signal: AbortSignal.timeout(10000),
        headers: { "Content-Type": "application/json", "Authorization": `Bearer ${accessToken}` },
        body: JSON.stringify({ message: {
          token: fcmToken, notification: { title, body }, ...(data ? { data } : {}),
          android: { priority: 'HIGH', notification: { sound: 'default' } },
          apns: { headers: { 'apns-priority': '10' }, payload: { aps: { sound: 'default' } } },
        } }),
      });
      // Consume the response so failed sends don't hold resources in a worker.
      await response.arrayBuffer();
      if (response.status === 401 && attempt === 0) {
        cachedToken = undefined;
        continue;
      }
      if (!response.ok) console.warn(`FCM send failed (HTTP ${response.status})`);
      return response.ok;
    }
  } catch {
    // Never log the service-account JSON, private key, device token or payload.
    console.warn("FCM delivery failed; check server credentials and connectivity");
  }
  return false;
}
