"""Synthetic regressions for moderation, event provenance and account erasure."""
import json
import secrets
import urllib.request
import urllib.error
import struct
import zlib
from pathlib import Path
exec(Path(__file__).with_name('probe_local.py').read_text().split('results = []')[0])

outcomes=[]
def report(name,response,predicate):
    status,data=response
    passed=predicate(status,data)
    outcomes.append(passed)
    print(json.dumps({'test':name,'passed':passed,'status':status}),flush=True)
    return data

denied=lambda s,d:s in (400,401,403) or (s==200 and d==[])
users=[];event_ids=[];files=[]
try:
    identities=[]
    for label in ('alice','bob','eve'):
        email=f'extended-{label}-{secrets.token_hex(6)}@vibra.test'
        password=secrets.token_urlsafe(24)+'Aa1!'
        status,user=req('/auth/v1/admin/users',ADMIN,'POST',{'email':email,'password':password,'email_confirm':True})
        assert status==200
        uid=user['id'];users.append(uid)
        assert req('/rest/v1/users',ADMIN,'POST',{'id':uid,'username':'ext'+secrets.token_hex(6)})[0]==201
        status,session=req('/auth/v1/token?grant_type=password',ANON,'POST',{'email':email,'password':password})
        assert status==200
        identities.append((uid,session['access_token']))
    (a,at),(b,bt),(e,et)=identities
    report('anonymous extension table route blocked',req('/rest/v1/spatial_ref_sys?limit=1',ANON),lambda s,d:s==403)
    report('authenticated extension table route blocked',req('/rest/v1/spatial_ref_sys?limit=1',at),lambda s,d:s==403)
    report('extension RPC route blocked',req('/rest/v1/rpc/st_estimatedextent',at,'POST',{'text':'users'}),lambda s,d:s in (403,404))
    report('graphql cannot bypass application API guard',req('/graphql/v1',at,'POST',{'query':'{__typename}'}),lambda s,d:s in (401,403,404))
    assert req('/rest/v1/friendships',ADMIN,'POST',{'requester_id':a,'receiver_id':b,'status':'accepted'})[0]==201
    status,m=req('/rest/v1/messages',ADMIN,'POST',{'sender_id':a,'receiver_id':b,'content':'synthetic sender secret'})
    assert status==201
    mid=m[0]['id']
    report('recipient cannot forge sender reaction',req('/rest/v1/messages?id=eq.'+mid,bt,'PATCH',{'reactions':{a:'forged'}}),denied)
    report('recipient cannot hide chat for sender',req('/rest/v1/messages?id=eq.'+mid,bt,'PATCH',{'deleted_by':[a]}),denied)
    report('reaction RPC accepts own reaction',req('/rest/v1/rpc/react_to_message',bt,'POST',{'p_message_id':mid,'p_user_id':b,'p_reaction':'❤️'}),lambda s,d:s==204)
    report('reaction RPC rejects oversized payload',req('/rest/v1/rpc/react_to_message',bt,'POST',{'p_message_id':mid,'p_user_id':b,'p_reaction':'x'*5000}),denied)
    report('support status is backend managed',req('/rest/v1/support_reports',at,'POST',{'user_id':a,'description':'synthetic test report','status':'resolved'},prefer='return=minimal'),denied)
    report('legitimate support report accepted',req('/rest/v1/support_reports',at,'POST',{'user_id':a,'description':'synthetic legitimate report'},prefer='return=minimal'),lambda s,d:s==201)
    report('moderation status is backend managed',req('/rest/v1/reports',at,'POST',{'reporter_id':a,'reported_id':b,'reason':'synthetic','status':'action_taken'}),denied)
    report('report cannot reference outsider message',req('/rest/v1/reports',et,'POST',{'reporter_id':e,'reported_id':a,'message_id':mid,'reason':'synthetic'}),denied)
    event={'external_id':'pentest-'+secrets.token_hex(8),'source':'ticketmaster','name':'forged provider event','event_date':'2027-09-11T20:00:00Z','ticket_url':'https://example.invalid/phishing'}
    response=req('/rest/v1/events',at,'POST',event)
    if response[0]==201:event_ids.append(response[1][0]['id'])
    report('client cannot publish unverified canonical event',response,denied)
    canonical={**event,'external_id':'canonical-'+secrets.token_hex(8),'name':'verified fixture'}
    status,saved=req('/rest/v1/events',ADMIN,'POST',canonical)
    assert status==201
    event_ids.append(saved[0]['id'])
    report('event resolver uses canonical existing event',req('/functions/v1/resolve-event',at,'POST',{'source':canonical['source'],'external_id':canonical['external_id'],'name':'ignored spoof'}),lambda s,d:s==200 and d.get('id')==saved[0]['id'])
    report('profile cannot be deleted outside erasure endpoint',req('/rest/v1/users?id=eq.'+a,at,'DELETE'),denied)
    report('legacy erasure RPC cannot bypass storage cleanup',req('/rest/v1/rpc/delete_user_account',at,'POST',{}),denied)
    path=a+'/fake-'+secrets.token_hex(4)+'.png';files.append(('support-attachments',path))
    request=urllib.request.Request(BASE+'/storage/v1/object/support-attachments/'+path,data=b'<script>synthetic</script>',method='POST',headers={'apikey':ANON,'Authorization':'Bearer '+at,'Content-Type':'image/png'})
    try:
        with urllib.request.urlopen(request) as r:status=r.status
    except urllib.error.HTTPError as error:status=error.code
    report('support uploads must use validated gateway',(status,None),lambda s,d:s>=400)
    def chunk(kind,data):return struct.pack('!I',len(data))+kind+data+struct.pack('!I',zlib.crc32(kind+data)&0xffffffff)
    png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('!IIBBBBB',1,1,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(b'\0\xff\0\0\xff'))+chunk(b'IEND',b'')
    def upload(endpoint,token,data):
        request=urllib.request.Request(BASE+endpoint,data=data,method='POST',headers={'apikey':ANON,'Authorization':'Bearer '+token,'Content-Type':'image/png'})
        try:
            with urllib.request.urlopen(request) as r:return r.status,json.load(r)
        except urllib.error.HTTPError as error:return error.code,None
    # Orphans have no message/profile reference, but erasure must remove them.
    for bucket in ('avatars','chat-media','support-attachments'):
        path=a+'/orphan-'+secrets.token_hex(5)+'.png';files.append((bucket,path))
        assert upload('/storage/v1/object/'+bucket+'/'+path,ADMIN,png)[0]==200
    support=report('support gateway accepts real screenshot',upload('/functions/v1/upload-image?bucket=support-attachments',at,png),lambda s,d:s==200)
    if support and support.get('path'):files.append(('support-attachments',support['path']))
    report('truncated JPEG fails without server error',upload('/functions/v1/upload-image',at,b'\xff\xd8'+b'\xff'*12),lambda s,d:s==415)
    # Bidirectional history reproduces nullable-participant cascade failures.
    assert req('/rest/v1/messages',ADMIN,'POST',{'sender_id':b,'receiver_id':a,'content':'synthetic reply'})[0]==201
    status,log=req('/rest/v1/auth_errors_log',ADMIN,'POST',{'user_id':a,'error_code':'synthetic','error_message':'synthetic private diagnostic'})
    assert status==201
    log_id=log[0]['id']
    report('client cannot mark another account for erasure',req('/rest/v1/rpc/begin_account_erasure',bt,'POST',{'p_user_id':a}),denied)
    assert req('/rest/v1/rpc/begin_account_erasure',ADMIN,'POST',{'p_user_id':a})[0]==204
    late_path=a+'/late-'+secrets.token_hex(5)+'.png';files.append(('avatars',late_path))
    report('inflight upload cannot register after erasure begins',upload('/storage/v1/object/avatars/'+late_path,ADMIN,png),lambda s,d:s>=400)
    response=req('/functions/v1/delete-account',at,'POST',{})
    report('account erasure succeeds with conversation history',response,lambda s,d:s==200 and d.get('deleted') is True)
    if response[0]==200:
        status,row=req('/auth/v1/admin/users/'+a,ADMIN)
        report('erasure removes Auth row',(status,row),lambda s,d:s==404)
        if status==404:users.remove(a)
        report('erasure removes private profile',req('/rest/v1/users?id=eq.'+a,ADMIN),lambda s,d:s==200 and d==[])
        report('erasure deletes private diagnostics',req('/rest/v1/auth_errors_log?id=eq.'+log_id,ADMIN),lambda s,d:s==200 and d==[])
        report('erasure revokes old JWT',req('/rest/v1/users',at),lambda s,d:s==401)
        for bucket in ('avatars','chat-media','support-attachments'):
            report('erasure removes orphan '+bucket,req('/storage/v1/object/list/'+bucket,ADMIN,'POST',{'prefix':a+'/','limit':100}),lambda s,d:s==200 and d==[])
        report('other participant survives erasure',req('/rest/v1/users?id=eq.'+b,bt),lambda s,d:s==200 and len(d)==1)
finally:
    for bucket,path in files:req('/storage/v1/object/'+bucket,ADMIN,'DELETE',{'prefixes':[path]})
    for event_id in event_ids:req('/rest/v1/events?id=eq.'+event_id,ADMIN,'DELETE')
    for uid in users:cleanup_user(uid)
if not all(outcomes):raise SystemExit(1)
