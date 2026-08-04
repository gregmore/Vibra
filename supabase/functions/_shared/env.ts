export function requireEnv(key: string): string {
  const value = Deno.env.get(key)?.trim();
  if (!value) {
    throw new Error(`Missing env var: ${key}`);
  }
  return value;
}

export function optionalEnv(key: string): string | null {
  const value = Deno.env.get(key)?.trim();
  return value && value.length > 0 ? value : null;
}

