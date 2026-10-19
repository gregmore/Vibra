#!/usr/bin/env bash
# Run every pgTAP file against a running local Supabase stack. Mounting the
# entire test tree preserves psql's relative \ir includes, unlike passing only
# database/*.sql to Supabase CLI versions that omit the shared setup include.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 LOCAL_SUPABASE_WORKDIR" >&2
  exit 2
fi

repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
local_workdir="$(cd "$1" && pwd)"
config_file="$local_workdir/supabase/config.toml"
if [[ ! -f "$config_file" ]]; then
  echo "Local Supabase configuration not found: $config_file" >&2
  exit 2
fi
project_id="$(sed -nE 's/^project_id[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$config_file")"
if [[ ! "$project_id" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "The local Supabase project_id must be an explicit safe identifier." >&2
  exit 2
fi
db_container="supabase_db_$project_id"
if [[ "$(docker inspect --format '{{.State.Running}}' "$db_container" 2>/dev/null)" != true ]]; then
  echo "The local database container is not running: $db_container" >&2
  exit 2
fi

# No hosted URL or arbitrary database target is accepted. The test process can
# connect only through the named local database container's network namespace.
# pgTAP fixtures run inside BEGIN/ROLLBACK in each file.
export PGPASSWORD="${LOCAL_DB_PASSWORD:-postgres}"
echo "Running all pgTAP files against local container $db_container"
# Official Docker Hub mirror avoids shared ECR download quotas in hosted CI.
docker run --rm \
  --network "container:$db_container" \
  --mount "type=bind,src=$repo_root/supabase/tests,dst=/tests,readonly" \
  --env PGPASSWORD \
  supabase/pg_prove:3.36 \
  sh -c 'exec pg_prove --host 127.0.0.1 --port 5432 --username postgres --dbname postgres --verbose /tests/*.sql /tests/database/*.sql'
