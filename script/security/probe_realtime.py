"""Synthetic private-chat subscription test on the dedicated local stack."""
import asyncio
import json
import secrets
from pathlib import Path
from websockets.asyncio.client import connect

# Reuse the strictly loopback-only HTTP helper without executing its probes.
exec(Path(__file__).with_name('probe_local.py').read_text().split('results = []')[0])

async def join(token):
    ws = await connect(BASE.replace('https:', 'wss:').replace('http:', 'ws:') + '/realtime/v1/websocket?apikey=' + ANON + '&vsn=1.0.0')
    await ws.send(json.dumps({'topic':'realtime:pentest', 'event':'phx_join', 'ref':'1', 'payload':{
        'config':{'broadcast':{'self':False}, 'presence':{'key':''},
                  'postgres_changes':[{'event':'INSERT','schema':'public','table':table} for table in ['messages','user_matches']]},
        'access_token':token}}))
    for _ in range(10):
        message = json.loads(await asyncio.wait_for(ws.recv(), 10))
        if message.get('event') == 'phx_reply':
            assert message['payload']['status'] == 'ok', message
        if message.get('event') == 'system':
            assert message['payload']['status'] == 'ok', message
            return ws
    raise RuntimeError('Realtime subscription did not become ready')

async def collect(ws):
    records = []
    async def receive():
        while True:
            message = json.loads(await ws.recv())
            if message.get('event') == 'postgres_changes': records.append(message['payload'])
    try:
        await asyncio.wait_for(receive(), 4)
    except asyncio.TimeoutError: pass
    return records

async def main():
    users=[]; sockets=[]; owner_token=None
    try:
        for label in ['alice','bob','eve']:
            email=f'rt-{label}-{secrets.token_hex(5)}@vibra.test'; password=secrets.token_urlsafe(24)+'Aa1!'
            status,u=req('/auth/v1/admin/users',ADMIN,'POST',{'email':email,'password':password,'email_confirm':True})
            assert status==200,(status,u)
            users.append(u['id'])
            assert req('/rest/v1/users',ADMIN,'POST',{'id':u['id'],'username':label+secrets.token_hex(4)})[0]==201
            status,s=req('/auth/v1/token?grant_type=password',ANON,'POST',{'email':email,'password':password})
            assert status==200,(status,s)
            if label=='alice': owner_token=s['access_token']
            if label!='bob': sockets.append(await join(s['access_token']))
        a,b,e=users
        assert req('/rest/v1/friendships',ADMIN,'POST',{'requester_id':a,'receiver_id':b,'status':'accepted'})[0]==201
        status,m=req('/rest/v1/messages',ADMIN,'POST',{'sender_id':a,'receiver_id':b,'content':'realtime synthetic secret'})
        assert status==201,(status,m)
        first,second=sorted([a,b])
        status,match=req('/rest/v1/user_matches',ADMIN,'POST',{'user_id_a':first,'user_id_b':second,'compatibility':80})
        assert status==201,(status,match)
        owner,outsider=await asyncio.gather(*(collect(ws) for ws in sockets))
        print(json.dumps({'test':'Realtime message and match owner positive control','passed':len(owner)==2,'events':len(owner)}))
        print(json.dumps({'test':'Realtime message and match unrelated user','passed':not outsider,'events':len(outsider)}))
        assert len(owner)==2 and not outsider
        assert req('/auth/v1/logout?scope=local',owner_token,'POST')[0]==204
        assert req('/rest/v1/messages',ADMIN,'POST',{'sender_id':a,'receiver_id':b,'content':'after logout secret'})[0]==201
        after=await collect(sockets[0])
        print(json.dumps({'test':'Existing Realtime subscription after logout','passed':not after,'events':len(after)}))
        assert not after
    finally:
        for ws in sockets: await ws.close()
        for uid in users: cleanup_user(uid)

asyncio.run(main())
