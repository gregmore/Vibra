"""Management operations restricted to the explicitly provisioned empty staging."""
import json
import subprocess
import urllib.request
from pathlib import Path

STAGING_REF = 'ppecqwnctxygbofdmxkf'
STAGING_URL = 'https://' + STAGING_REF + '.supabase.co'
STATE = Path.home() / '.supabase/vibra-staging/credentials.json'


def credentials():
    data = json.loads(STATE.read_text())
    if data['project']['id'] != STAGING_REF:
        raise RuntimeError('Refusing unexpected staging project')
    return data


def management(path, method='GET', body=None):
    if not path.startswith('/v1/projects/' + STAGING_REF + '/'):
        raise ValueError('Management target must be the dedicated staging project')
    credentials()
    token = subprocess.check_output([
        'security', 'find-generic-password', '-s', 'Supabase CLI',
        '-a', 'supabase', '-w'], stderr=subprocess.DEVNULL).decode().strip()
    request = urllib.request.Request('https://api.supabase.com' + path,
        method=method, data=None if body is None else json.dumps(body).encode(),
        headers={'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json'})
    with urllib.request.urlopen(request, timeout=60) as response:
        raw = response.read()
    return json.loads(raw) if raw else None


def query(sql):
    return management('/v1/projects/' + STAGING_REF + '/database/query',
                      'POST', {'query': sql})
