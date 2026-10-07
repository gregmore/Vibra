"""Synthetic regression probes: local by default, explicit dedicated staging opt-in."""
import json
import os
import secrets
import urllib.request
import urllib.error
from pathlib import Path

if os.environ.get('VIBRA_PENTEST_STAGING') == '1':
    from staging_admin import credentials, STAGING_URL
    staging = credentials()
    config = {'API_URL': STAGING_URL, 'ANON_KEY': staging['anon'],
              'SERVICE_ROLE_KEY': staging['service_role']}
else:
    config = json.loads(Path('/tmp/vibra-pentest-status.json').read_text())
    if config['API_URL'] not in ('http://127.0.0.1:55321', 'http://localhost:55321'):
        raise RuntimeError('Refusing non-test target')
BASE = config['API_URL']
ANON = config['ANON_KEY']
ADMIN = config['SERVICE_ROLE_KEY']

def req(path, token=ANON, method='GET', body=None, prefer='return=representation'):
    data = None if body is None else json.dumps(body).encode()
    r = urllib.request.Request(BASE + path, data=data, method=method,
        headers={'apikey': ANON, 'Authorization': 'Bearer ' + token,
                 'Content-Type': 'application/json', 'Prefer': prefer})
    try:
        with urllib.request.urlopen(r, timeout=30) as response:
            raw = response.read()
            return response.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        raw = e.read()
        try: raw = json.loads(raw)
        except ValueError: raw = raw.decode()
        return e.code, raw

def cleanup_user(uid):
    # These messages are disposable fixtures, not retained conversation data.
    # Delete them explicitly: the immutable-column trigger rejects the FK's
    # SET NULL when an admin deletes an account with conversation history.
    import uuid
    uid = str(uuid.UUID(uid))
    status, _ = req('/rest/v1/messages?or=(sender_id.eq.'+uid+',receiver_id.eq.'+uid+')', ADMIN, 'DELETE')
    if status not in (200,204):
        raise RuntimeError('Synthetic message cleanup failed: HTTP '+str(status))
    status, _ = req('/auth/v1/admin/users/'+uid, ADMIN, 'DELETE')
    if status not in (200,204):
        raise RuntimeError('Synthetic account cleanup failed: HTTP '+str(status))

results = []
def check(name, response, predicate):
    status, data = response
    passed = predicate(status, data)
    results.append({'test': name, 'passed': passed, 'status': status})
    print(json.dumps(results[-1]))
    return data

users = []
try:
    for label in ('alice', 'bob', 'eve'):
        email = f'{label}-{secrets.token_hex(5)}@vibra.test'
        password = secrets.token_urlsafe(24) + 'Aa1!'
        status, user = req('/auth/v1/admin/users', ADMIN, 'POST',
            {'email': email, 'password': password, 'email_confirm': True})
        assert status == 200, (status, user)
        uid = user['id']
        users.append(uid)
        status, profile = req('/rest/v1/users', ADMIN, 'POST', {'id': uid, 'username': label + secrets.token_hex(4)})
        assert status == 201, (status, profile)
        status, session = req('/auth/v1/token?grant_type=password', ANON, 'POST', {'email': email, 'password': password})
        assert status == 200, (status, session)
        globals()[label] = (uid, session['access_token'])
    a, at = alice; b, bt = bob; e, et = eve
    denied = lambda s, d: s in (401, 403) or (s == 200 and d == [])
    check('anonymous private profiles', req('/rest/v1/users'), denied)
    check('cross-user private profile read', req('/rest/v1/users?id=eq.' + b, at), denied)
    check('cross-user profile update', req('/rest/v1/users?id=eq.' + b, at, 'PATCH', {'bio': 'tampered'}), denied)
    check('forged Spotify identity', req('/rest/v1/users?id=eq.' + a, at, 'PATCH', {'spotify_id': 'forged-' + a}), lambda s,d: s in (400,401,403))
    check('forged musical profile', req('/rest/v1/music_profiles', at, 'POST', {'user_id': a, 'top_artists': [{'id':'forged'}]}), lambda s,d: s in (400,401,403))
    assert req('/rest/v1/music_profiles', ADMIN, 'POST', {'user_id':b,'top_artists':[{'id':'private-artist'}]})[0]==201
    check('music discovery without consent', req('/rest/v1/music_profiles_public?user_id=eq.'+b, at), denied)
    assert req('/rest/v1/privacy_preferences', ADMIN, 'POST', {'user_id':b,'spotify_matching':True})[0]==201
    check('music discovery with explicit consent', req('/rest/v1/music_profiles_public?user_id=eq.'+b, at), lambda s,d:s==200 and len(d)==1)
    friendship = check('self-accepted friendship', req('/rest/v1/friendships', at, 'POST', {'requester_id': a, 'receiver_id': b, 'status': 'accepted'}), lambda s,d: s in (400,401,403))
    req('/rest/v1/friendships?requester_id=eq.' + a, ADMIN, 'DELETE')
    status, f = req('/rest/v1/friendships', ADMIN, 'POST', {'requester_id': a, 'receiver_id': b, 'status': 'accepted'})
    assert status == 201, (status,f)
    check('unrelated friendship update', req('/rest/v1/friendships?id=eq.'+f[0]['id'], et, 'PATCH', {'status':'rejected'}), denied)
    status, m = req('/rest/v1/messages', ADMIN, 'POST', {'sender_id':a, 'receiver_id':b, 'content':'original'})
    assert status == 201, (status,m)
    mid = m[0]['id']
    check('unrelated message read', req('/rest/v1/messages?id=eq.'+mid, et), denied)
    check('recipient rewrites sender message', req('/rest/v1/messages?id=eq.'+mid, bt, 'PATCH', {'content':'forged'}), lambda s,d: s in (400,401,403))
    check('recipient may mark read', req('/rest/v1/messages?id=eq.'+mid, bt, 'PATCH', {'read_at':'2026-09-11T12:00:00Z'}), lambda s,d:s==200 and len(d)==1)
    check('recipient cannot substitute private media', req('/rest/v1/messages?id=eq.'+mid, bt, 'PATCH', {'media_path':e+'/private.png'}), lambda s,d:s in (400,403))
    check('saved events isolation', req('/rest/v1/event_attendees?user_id=eq.'+b, at), denied)
    check('Spotify credentials isolation', req('/rest/v1/spotify_connections', at), denied)
    check('overlong bio', req('/rest/v1/users?id=eq.'+a, at, 'PATCH', {'bio':'x'*501}), lambda s,d:s==400)
    check('own profile positive control', req('/rest/v1/users?id=eq.'+a, at), lambda s,d:s==200 and len(d)==1)
    check('retired seed endpoint', req('/functions/v1/seed-compatible-users', at, 'POST', {}), lambda s,d:s==410)
    check('embedding job restricted to backend', req('/functions/v1/compute-event-embeddings', at, 'POST', {}), lambda s,d:s==403)
    for i in range(10):
        check('action quota allowed '+str(i), req('/rest/v1/rpc/consume_action_limit', at, 'POST', {'p_action':'spotify-token-exchange'}), lambda s,d:s==204)
    check('action quota exceeded', req('/rest/v1/rpc/consume_action_limit', at, 'POST', {'p_action':'spotify-token-exchange'}), lambda s,d:s==429)
    check('another user has independent quota', req('/rest/v1/rpc/consume_action_limit', bt, 'POST', {'p_action':'spotify-token-exchange'}), lambda s,d:s==204)
    check('logout', req('/auth/v1/logout?scope=global', at, 'POST'), lambda s,d:s==204)
    check('JWT replay after logout', req('/rest/v1/users?id=eq.'+a, at), lambda s,d:s==401)
    check('revoked JWT cannot call definer export', req('/rest/v1/rpc/export_my_personal_data', at, 'POST', {}), lambda s,d:s==401)
    for function in ('calculate-match','recommend-events','spotify-token-exchange','sync-music-profile','track-ticket-click','spotify-disconnect','delete-account'):
        check('revoked JWT '+function, req('/functions/v1/'+function, at, 'POST', {}), lambda s,d:s==401)
finally:
    for uid in users:
        cleanup_user(uid)

if any(not item['passed'] for item in results):
    raise SystemExit(1)
