#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"
python3 script/security/prepare_client_env.py

if ! command -v supabase >/dev/null 2>&1; then
  echo "Supabase CLI non trovata." >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js non trovato." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker non trovato. Installa Docker Desktop prima di continuare." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Docker non e' avviato." >&2
    exit 1
  fi

  echo "Docker Desktop non e' attivo: lo avvio..."
  open -a Docker
  for _ in {1..45}; do
    if docker info >/dev/null 2>&1; then
      break
    fi
    sleep 2
  done

  if ! docker info >/dev/null 2>&1; then
    echo "Docker Desktop non e' diventato disponibile entro 90 secondi." >&2
    exit 1
  fi
fi

if ! status_json="$(supabase status -o json 2>/dev/null)"; then
  echo "Supabase locale non e' attivo: lo avvio..."
  if ! start_output="$(supabase start 2>&1)"; then
    # Dopo una chiusura forzata di Docker, la CLI può trovare container
    # registrati ma spenti. Il ciclo stop/start conserva i dati nel volume.
    echo "Ripristino i container Supabase dal backup locale..."
    supabase stop >/dev/null
    if ! start_output="$(supabase start 2>&1)"; then
      echo "$start_output" >&2
      exit 1
    fi
  fi
  status_json="$(supabase status -o json 2>/dev/null)"
fi

local_url="$(STATUS_JSON="$status_json" node -e "process.stdout.write(JSON.parse(process.env.STATUS_JSON).API_URL)")"
local_anon_key="$(STATUS_JSON="$status_json" node -e "process.stdout.write(JSON.parse(process.env.STATUS_JSON).ANON_KEY)")"

if [[ "$local_url" != http://127.0.0.1:* && "$local_url" != http://localhost:* ]]; then
  echo "Target locale inatteso: $local_url" >&2
  exit 1
fi

echo "Avvio Vibra con i dati di test locali ($local_url)."
echo "Login consigliato: vibra_test_01_complete@example.com"
echo "Password predefinita: Vibra-Test!2026"

exec flutter run \
  --dart-define="VIBRA_E2E_SUPABASE_URL=$local_url" \
  --dart-define="VIBRA_E2E_SUPABASE_ANON_KEY=$local_anon_key" \
  "$@"
