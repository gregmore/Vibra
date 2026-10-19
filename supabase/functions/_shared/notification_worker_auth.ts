/** Authenticate the stable credential shared with the notification scheduler.
 *
 * Hosted SUPABASE_SERVICE_ROLE_KEY may differ from the project's legacy API
 * key stored in Vault. The explicit worker key keeps that comparison stable.
 * Gateway JWT verification remains enabled; this is the handler's extra check.
 */
export async function notificationWorkerAuthorized(request: Request): Promise<boolean> {
  const expected = Deno.env.get("VIBRA_NOTIFICATION_WORKER_KEY") ??
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authorization = request.headers.get("Authorization");
  if (!expected || expected.length < 32 || !authorization?.startsWith("Bearer ") ||
      authorization.length > 8192) return false;
  const actual = authorization.slice(7);
  const encoder = new TextEncoder();
  const [left, right] = await Promise.all([expected, actual].map((value) =>
    crypto.subtle.digest("SHA-256", encoder.encode(value))
  ));
  const a = new Uint8Array(left), b = new Uint8Array(right);
  let difference = 0;
  for (let index = 0; index < a.length; index++) difference |= a[index] ^ b[index];
  return difference === 0;
}
