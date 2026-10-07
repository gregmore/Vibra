"""Bounded Auth/Storage checks; run last because login throttling is intentional."""
import json
import secrets
import subprocess
import urllib.request
import urllib.error
import struct
import zlib
from pathlib import Path
exec(Path(__file__).with_name('probe_local.py').read_text().split('results = []')[0])

outcomes=[]
def report(name, passed, **evidence):
    outcomes.append(passed)
    print(json.dumps({'test':name,'passed':passed,**evidence}),flush=True)

def sql_scalar(sql):
    if os.environ.get('VIBRA_PENTEST_STAGING') == '1':
        from staging_admin import query
        rows=query(sql)
        return next(iter(rows[0].values())) if rows else None
    return subprocess.check_output(['docker','exec','supabase_db_vibra-pentest-20260911',
        'psql','-U','postgres','-d','postgres','-Atc',sql]).decode().strip()

email=f'auth-{secrets.token_hex(6)}@vibra.test'; password=secrets.token_urlsafe(24)+'Aa1!'
status,u=req('/auth/v1/admin/users',ADMIN,'POST',{'email':email,'password':password,'email_confirm':True})
assert status==200,(status,u)
uid=u['id']; paths=[]
try:
    req('/rest/v1/users',ADMIN,'POST',{'id':uid,'username':'auth'+secrets.token_hex(5)})
    sessions=[]
    for _ in range(2):
        status,s=req('/auth/v1/token?grant_type=password',ANON,'POST',{'email':email,'password':password})
        assert status==200,(status,s)
        sessions.append(s)
    token=sessions[0]['access_token']
    hash_check=sql_scalar("SELECT encrypted_password LIKE '$2%' FROM auth.users WHERE id='"+uid+"'")
    report('password stored as bcrypt hash',hash_check is True or hash_check=='t')
    status,_=req('/auth/v1/user',token,'PUT',{'password':'short'})
    report('short password rejected server-side',status in (400,422),status=status)
    path=uid+'/fake-'+secrets.token_hex(3)+'.png'; paths.append(path)
    r=urllib.request.Request(BASE+'/storage/v1/object/avatars/'+path,data=b'<script>alert(1)</script>',method='POST',
        headers={'apikey':ANON,'Authorization':'Bearer '+token,'Content-Type':'image/png'})
    try:
        with urllib.request.urlopen(r,timeout=15) as response: status=response.status
    except urllib.error.HTTPError as error: status=error.code
    report('storage rejects fake PNG content',status>=400,status=status)
    def image_upload(data):
        r=urllib.request.Request(BASE+'/functions/v1/upload-image',data=data,method='POST',
            headers={'apikey':ANON,'Authorization':'Bearer '+token,'Content-Type':'application/octet-stream'})
        try:
            with urllib.request.urlopen(r,timeout=60) as response: return response.status,json.load(response)
        except urllib.error.HTTPError as error: return error.code,error.read().decode()
    status,_=image_upload(b'<script>alert(1)</script>')
    report('image gateway rejects disguised script',status==415,status=status)
    def chunk(kind,data): return struct.pack('!I',len(data))+kind+data+struct.pack('!I',zlib.crc32(kind+data)&0xffffffff)
    png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('!IIBBBBB',1,1,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(b'\0\xff\0\0\xff'))+chunk(b'IEND',b'')
    status,image=image_upload(png+b'<script>appended</script>')
    report('image gateway accepts and re-encodes real PNG',status==200,status=status)
    if status==200:
        paths.append(image['path'])
        with urllib.request.urlopen(BASE+'/storage/v1/object/public/avatars/'+image['path']) as response: cleaned=response.read()
        report('image gateway strips appended payload',b'<script>' not in cleaned)
    status,_=req('/auth/v1/logout?scope=local',token,'POST')
    report('local logout succeeds',status==204,status=status)
    status,_=req('/rest/v1/users',token)
    report('local logout revokes first JWT',status==401,status=status)
    status,data=req('/rest/v1/users',sessions[1]['access_token'])
    report('local logout preserves other device',status==200 and len(data)==1,status=status)
    status,_=req('/auth/v1/token?grant_type=refresh_token',ANON,'POST',{'refresh_token':sessions[0]['refresh_token']})
    report('logged-out refresh token rejected',status in (400,401),status=status)
    req('/auth/v1/logout?scope=global',sessions[1]['access_token'],'POST')
    status,_=req('/rest/v1/users',sessions[1]['access_token'])
    report('global logout revokes remaining device',status==401,status=status)
    statuses=[]
    for _ in range(35):
        status,_=req('/auth/v1/token?grant_type=password',ANON,'POST',{'email':email,'password':'wrong-password-Aa1!'})
        statuses.append(status)
        if status==429:break
    report('bounded failed-login rate limit',429 in statuses,attempts=len(statuses),statuses=statuses)
    hook_lockout=sql_scalar("SELECT EXISTS (SELECT 1 FROM vibra_private.password_attempts WHERE user_id='"+uid+"' AND failures>=5)")
    if hook_lockout is True or hook_lockout=='t':
        status,_=req('/auth/v1/token?grant_type=password',ANON,'POST',{'email':email,'password':password})
        report('temporary lockout also stops a correct password',status==429,status=status)
        sql_scalar("UPDATE vibra_private.password_attempts SET window_start=now()-interval '16 minutes' WHERE user_id='"+uid+"'")
        status,_=req('/auth/v1/token?grant_type=password',ANON,'POST',{'email':email,'password':password})
        report('expired lockout permits legitimate login',status==200,status=status)
    else:
        # A gateway 429 or transient recovery does not prove the SQL hook ran.
        for name in ('temporary lockout also stops a correct password',
                     'expired lockout permits legitimate login'):
            report(name,None,skipped='No account lockout recorded by password hook')
finally:
    req('/storage/v1/object/avatars',ADMIN,'DELETE',{'prefixes':paths})
    cleanup_user(uid)

if not all(outcomes):
    raise SystemExit(1)
