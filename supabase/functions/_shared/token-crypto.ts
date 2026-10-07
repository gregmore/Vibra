// Versioned AES-GCM envelope for third-party OAuth tokens stored in Postgres.
// Set SPOTIFY_TOKEN_ENCRYPTION_KEY to a base64-encoded 32-byte key.
const encoder = new TextEncoder();
const decoder = new TextDecoder();

function encode(bytes: Uint8Array) {
  return btoa(String.fromCharCode(...bytes));
}

function decode(value: string) {
  return Uint8Array.from(atob(value), (char) => char.charCodeAt(0));
}

async function key() {
  const raw = Deno.env.get("SPOTIFY_TOKEN_ENCRYPTION_KEY");
  if (!raw) throw new Error("Missing SPOTIFY_TOKEN_ENCRYPTION_KEY");
  const bytes = decode(raw);
  if (bytes.byteLength !== 32) throw new Error("SPOTIFY_TOKEN_ENCRYPTION_KEY must be a base64 32-byte key");
  return crypto.subtle.importKey("raw", bytes, "AES-GCM", false, ["encrypt", "decrypt"]);
}

export async function encryptToken(value: string) {
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const ciphertext = new Uint8Array(await crypto.subtle.encrypt({ name: "AES-GCM", iv }, await key(), encoder.encode(value)));
  return `v1.${encode(iv)}.${encode(ciphertext)}`;
}

export async function decryptToken(value: string) {
  const [version, iv, ciphertext] = value.split(".");
  if (version !== "v1" || !iv || !ciphertext) throw new Error("Unsupported encrypted Spotify token format");
  const plaintext = await crypto.subtle.decrypt({ name: "AES-GCM", iv: decode(iv) }, await key(), decode(ciphertext));
  return decoder.decode(plaintext);
}
