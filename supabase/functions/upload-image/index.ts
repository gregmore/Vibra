import { decode, Image } from "https://deno.land/x/imagescript@1.3.0/mod.ts";
import { rejectRevokedSession } from "../_shared/session-guard.ts";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { corsHeaders, handleOptions } from "../_shared/cors.ts";

const headers = { ...corsHeaders, "Content-Type": "application/json" };
function reply(status: number, error: string) {
  return new Response(JSON.stringify({ error }), { status, headers });
}

// Read dimensions before allocating the decoded bitmap. Accept only JPEG/PNG.
function dimensions(bytes: Uint8Array): [number, number] | null {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  if (bytes.length >= 24 && bytes.slice(0,8).join() === "137,80,78,71,13,10,26,10") {
    return [view.getUint32(16), view.getUint32(20)];
  }
  if (bytes[0] !== 255 || bytes[1] !== 216) return null;
  let i = 2;
  while (i + 8 < bytes.length) {
    if (bytes[i++] !== 255) return null;
    while (bytes[i] === 255) i++;
    if (i + 3 > bytes.length) return null;
    const marker = bytes[i++];
    if (marker === 217 || marker === 218) return null;
    const length = view.getUint16(i);
    if (length < 2 || i + length > bytes.length) return null;
    if ([192,193,194].includes(marker)) {
      if (length < 8) return null;
      return [view.getUint16(i+5), view.getUint16(i+3)];
    }
    i += length;
  }
  return null;
}

Deno.serve(async (req) => {
  const options = handleOptions(req); if (options) return options;
  if (req.method !== "POST") return reply(405, "method_not_allowed");
  const rejected = await rejectRevokedSession(req, "upload-image"); if (rejected) return rejected;
  const bucket = new URL(req.url).searchParams.get("bucket") ?? "avatars";
  if (!["avatars", "chat-media", "support-attachments"].includes(bucket)) return reply(400, "invalid_bucket");
  const maximum = bucket === "chat-media" ? 10*1024*1024 : 5*1024*1024;
  const reader = req.body?.getReader(); if (!reader) return reply(400, "missing_image");
  const chunks: Uint8Array[] = []; let length = 0;
  while (true) {
    const { done, value } = await reader.read(); if (done) break;
    length += value.length;
    if (length > maximum) { await reader.cancel(); return reply(413, "image_too_large"); }
    chunks.push(value);
  }
  const bytes = new Uint8Array(length); let offset = 0;
  for (const chunk of chunks) { bytes.set(chunk, offset); offset += chunk.length; }
  const size = dimensions(bytes);
  if (!size || size.some(n => n < 1 || n > 4096) || size[0]*size[1] > 8_000_000) return reply(415, "invalid_image_dimensions_or_format");
  try {
    const decoded = await decode(bytes, true);
    if (!(decoded instanceof Image) || decoded.width < 1 || decoded.height < 1 || decoded.width > 4096 || decoded.height > 4096 || decoded.width * decoded.height > 8_000_000) return reply(415, "unsupported_image");
    // Re-encoding removes metadata, appended scripts and polyglot payloads.
    const png = await decoded.encode();
    if (png.length > maximum) return reply(413, "image_too_large");
    const admin = createSupabaseServiceClient();
    const { data: { user }, error } = await admin.auth.getUser((req.headers.get("Authorization") ?? "").replace(/^Bearer /, ""));
    if (error || !user) return reply(401, "unauthorized");
    const path = `${user.id}/${crypto.randomUUID()}.png`;
    const { error: uploadError } = await admin.storage.from(bucket).upload(path, png, { contentType: "image/png", upsert: false });
    if (uploadError) return reply(500, "upload_failed");
    const url = bucket === "avatars" ? admin.storage.from(bucket).getPublicUrl(path).data.publicUrl : null;
    return new Response(JSON.stringify({ path, url }), { headers });
  } catch { return reply(415, "invalid_image"); }
});
