#!/usr/bin/env bash
# Deploys the Spotify integration and the music affinity engine to the
# linked Supabase project, in the documented order. Stops at the first error.
set -euo pipefail
cd "$(dirname "$0")/../.."

echo "→ Project: $(cat supabase/.temp/project-ref)"

echo "→ 1/3 Migrations"
supabase db push --linked --yes

echo "→ 2/3 Edge Functions"
supabase functions deploy \
  spotify-token-exchange sync-music-profile spotify-sync-worker calculate-match \
  recommend-events search-events ticketmaster-sync spotify-disconnect --use-api

echo "→ 3/3 Spotify switch on"
supabase secrets set SPOTIFY_ENABLED=true

echo "✓ Done"
