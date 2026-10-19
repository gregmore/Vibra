"""Generate the mobile asset from an explicit allowlist; never bundle .env."""
from pathlib import Path
import base64
import json

root = Path(__file__).resolve().parents[2]
allowed = {'SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SPOTIFY_CLIENT_ID',
           'SPOTIFY_REDIRECT_URI', 'GOOGLE_WEB_CLIENT_ID', 'GOOGLE_IOS_CLIENT_ID',
           'BANDSINTOWN_APP_ID'}
lines = []
for line in (root / '.env').read_text().splitlines():
    key, sep, value = line.partition('=')
    if sep and key.strip() in allowed:
        if key.strip() == 'SUPABASE_ANON_KEY':
            raw = value.strip().strip('\"\'')
            if raw.startswith('sb_secret_'):
                raise SystemExit('Refusing a secret Supabase key in the mobile asset')
            if raw.count('.') == 2:
                payload = raw.split('.')[1]
                claims = json.loads(base64.urlsafe_b64decode(payload + '=' * (-len(payload) % 4)))
                if claims.get('role') != 'anon':
                    raise SystemExit('Mobile Supabase JWT must have the anon role')
        lines.append(line)
(root / '.env.public').write_text('\n'.join(lines) + '\n')
print('Generated .env.public using the public configuration allowlist')
