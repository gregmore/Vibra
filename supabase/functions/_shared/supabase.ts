import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

import { requireEnv } from "./env.ts";

export function createSupabaseServiceClient() {
  const url = requireEnv("SUPABASE_URL");
  const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");

  return createClient(url, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}

