// Dedicated server-to-server credential. Never supplied by the mobile app.
// This worker disables gateway JWT verification because pg_net uses a job
// credential, rather than a user JWT. Missing configuration always fails closed.
export async function catalogueJobAuthorized(
  request: Request,
): Promise<boolean> {
  const expected = Deno.env.get("VIBRA_CATALOGUE_JOB_SECRET");
  const actual = request.headers.get("x-vibra-job-secret");
  if (!expected || expected.length < 32 || !actual || actual.length > 256) {
    return false;
  }
  const encoder = new TextEncoder();
  const [a, b] = await Promise.all(
    [expected, actual].map((value) =>
      crypto.subtle.digest("SHA-256", encoder.encode(value))
    ),
  );
  const expectedBytes = new Uint8Array(a), actualBytes = new Uint8Array(b);
  let difference = 0;
  for (let index = 0; index < expectedBytes.length; index++) {
    difference |= expectedBytes[index] ^ actualBytes[index];
  }
  return difference === 0;
}
