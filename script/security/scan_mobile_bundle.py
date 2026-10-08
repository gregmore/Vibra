"""Inspect build artifacts for known server secrets without printing values."""
import base64,json,re,sys,zipfile
from pathlib import Path
root=Path(__file__).resolve().parents[2]
secrets={}
for line in (root/'.env').read_text().splitlines():
    name,sep,value=line.partition('=')
    name=name.strip();value=value.strip().strip('\"\'')
    if sep and len(value)>=12 and re.search(r'SECRET|SERVICE_ROLE|PASSWORD|TICKETMASTER_API_KEY|SONGKICK_API_KEY|ACCESS_TOKEN|REFRESH_TOKEN',name):secrets[name]=value
state=Path.home()/'.supabase/vibra-staging/credentials.json'
if state.exists():
    credentials=json.loads(state.read_text())
    for name in ['service_role','db_password']:
        if credentials.get(name):secrets['staging_'+name]=credentials[name]
artifact=Path(sys.argv[1]);findings=[];total=0

def scan(name,data):
    global total
    total+=1
    if name.endswith('/.env') or name=='.env':findings.append({'file':name,'issue':'raw environment file bundled'})
    if 'integration_test' in name.lower() or b'IntegrationTestPlugin' in data or b'vibra_e2e_v1' in data:
        findings.append({'file':name,'issue':'native test plugin or demo fixture bundled'})
    for key,value in secrets.items():
        if value.encode() in data or value.encode('utf-16le') in data:findings.append({'file':name,'issue':'known server secret','key_name':key})
    for jwt in re.findall(rb'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+',data):
        try:
            part=jwt.split(b'.')[1];claim=json.loads(base64.urlsafe_b64decode(part+b'='*(-len(part)%4)))
            if claim.get('role')=='service_role':findings.append({'file':name,'issue':'service_role JWT'})
        except Exception:pass
    if re.search(rb'sb_secret_[A-Za-z0-9_-]{20,}',data):findings.append({'file':name,'issue':'Supabase secret key format'})
if artifact.is_dir():
    for p in artifact.rglob('*'):
        if p.is_file():scan(str(p.relative_to(artifact)),p.read_bytes())
else:
    with zipfile.ZipFile(artifact) as archive:
        for item in archive.infolist():
            if not item.is_dir():scan(item.filename,archive.read(item))
print(json.dumps({'artifact':str(artifact.resolve()),'files_scanned':total,'known_secret_values_checked':len(secrets),'findings':findings},indent=2))
raise SystemExit(bool(findings))
