#!/usr/bin/env python3
"""Validate listing limits, PNG dimensions, links and public unauthenticated pages."""
import argparse
import hashlib
from html.parser import HTMLParser
import json
import os
import re
import struct
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'release/store-materials'
args = argparse.ArgumentParser()
args.add_argument('--online', action='store_true')
args.add_argument('--owner-config', type=Path,
                  default=Path(os.environ.get('VIBRA_OWNER_CONFIG', str(ROOT / 'store/owner.json'))),
                  help='Private owner JSON (default: store/owner.json or VIBRA_OWNER_CONFIG)')
args.add_argument('--documents-dir', type=Path, default=ROOT / 'release/store-documents')
args.add_argument('--defines-config', type=Path, default=ROOT / 'release/app-public-defines.json')
args.add_argument('--release-config', type=Path, default=ROOT / 'release/store-config.json')
options = args.parse_args()
try:
    owner_bytes = options.owner_config.read_bytes()
    owner = json.loads(owner_bytes)
except FileNotFoundError:
    args.error('Owner configuration is missing. Copy store/owner.example.json '
               'to ignored store/owner.json and fill it, or pass --owner-config.')
except (OSError, ValueError):
    args.error('Unable to read owner configuration as a JSON object.')
if not isinstance(owner, dict) or any(not isinstance(owner.get(key), str)
        for key in ('legal_name', 'legal_address', 'support_email', 'privacy_email',
                    'legal_email', 'public_site_url')):
    args.error('Complete the identity, contact and public site text fields in the private owner configuration.')
checks = []
def check(name, passed, detail=''):
    checks.append({'check': name, 'passed': bool(passed), 'detail': detail})

OUT.mkdir(parents=True, exist_ok=True)
documents = options.documents_dir
try:
    generation = json.loads((documents / 'generation.json').read_text())
    metadata = (documents / 'STORE_METADATA.md').read_text()
except (OSError, ValueError):
    args.error('Personalized documents are missing. Run build_site.py with the '
               'same private --owner-config before checking release materials.')
if not isinstance(generation, dict) or not isinstance(generation.get('documents'), dict):
    args.error('Personalized document manifest is invalid. Run build_site.py again.')
check('personalized documents use current owner configuration',
      isinstance(generation, dict) and generation.get('example_mode') is False
      and generation.get('owner_config_sha256') == hashlib.sha256(owner_bytes).hexdigest())
for name in ('STORE_METADATA.md', 'PRIVACY_POLICY.md', 'TERMS_OF_SERVICE.md', 'SUPPORT.md'):
    path = documents / name
    check(name + ' personalized copy', path.is_file() and
          hashlib.sha256(path.read_bytes()).hexdigest() == generation.get('documents', {}).get(name)
          and not re.search(rb'YOUR_|PLACEHOLDER|\{\{[A-Z_]+\}\}|@(?:[\w.-]+\.)?example\.(?:com|org|net)\b', path.read_bytes(), re.I))
limits = {'Nome':30,'Name':30,'Sottotitolo App Store':30,'App Store subtitle':30,
          'Descrizione breve Google Play':80,'Google Play short description':80,
          'Testo promozionale App Store':170,'App Store promotional text':170,
          'Parole chiave App Store':100,'App Store keywords':100}
for label, limit in limits.items():
    match = re.search(r'\*\*'+re.escape(label)+r':\*\* (.+)', metadata)
    value = match.group(1) if match else ''
    check(label, bool(value) and len(value)<=limit, f'{len(value)}/{limit}')
for label in ['Descrizione completa','Full description']:
    match = re.search(r'\*\*'+label+r':\*\*\n\n(.*?)(?=\n## |\Z)',metadata,re.S)
    value = match.group(1) if match else ''
    check(label, bool(value) and len(value)<=4000, f'{len(value)}/4000')

class Links(HTMLParser):
    def __init__(self): super().__init__(); self.links=[]; self.headings=0
    def handle_starttag(self,tag,attrs):
        values=dict(attrs)
        if tag=='a': self.links.append(values.get('href',''))
        if tag=='h1': self.headings+=1

site=ROOT/'store/site/dist'
check('public page count', len(list(site.glob('*.html'))) == 6)
for path in sorted(site.glob('*.html')):
    source=path.read_text(); parser=Links(); parser.feed(source)
    check(f'{path.name} heading',parser.headings==1)
    check(f'{path.name} email',owner['support_email'] in source)
    check(f'{path.name} no placeholders',not re.search(r'\b(?:INSERT|TODO|PLACEHOLDER)\b|YOUR_|\{\{[A-Z_]+\}\}|@(?:[\w.-]+\.)?example\.(?:com|org|net)\b',source,re.I))
    for link in parser.links:
        target=urllib.parse.urlparse(link)
        if not target.scheme and target.path:
            check(f'{path.name} → {link}',(site/target.path).is_file())
    if options.online:
        url=owner['public_site_url']+'/'+path.name
        try:
            request=urllib.request.Request(url, headers={
                'User-Agent':'Mozilla/5.0 (compatible; VibraStoreMaterials/1.0)',
                'Accept':'text/html'})
            with urllib.request.urlopen(request,timeout=25) as response:
                body=response.read().decode('utf-8')
                # Sites canonicalizes .html and adds hosting metadata outside main.
                # Require the exact page content and same origin, without cookies.
                main=re.search(r'<main id="contenuto">.*?</main>',source,re.S).group()
                same_origin=urllib.parse.urlparse(response.url).netloc==urllib.parse.urlparse(url).netloc
                passed=response.status==200 and same_origin and main in body
                check(f'public {path.name}',passed,f'HTTP {response.status}; matching page, no authentication')
        except Exception as error:
            check(f'public {path.name}',False,type(error).__name__)

from html import escape
for slug in ('privacy', 'termini'):
    path = site / f'{slug}.html'
    source = path.read_text() if path.is_file() else ''
    address = owner.get('legal_address', '').strip()
    check(f'{slug}.html owner address', bool(address) and escape(address) in source)

try:
    manifest=json.loads((OUT/'screenshots.json').read_text())
except (OSError, ValueError):
    args.error('Screenshots manifest is missing. Generate captures and run package_materials.py first.')
version_match=re.search(r'^version:\s*([^\r\n#]+)', (ROOT/'pubspec.yaml').read_text(), re.M)
expected_version=version_match.group(1).strip().strip("'\"") if version_match else ''
check('screenshot app version',bool(expected_version) and manifest.get('version') == expected_version, manifest.get('version','missing'))
sizes={'ios-medium':(1206,2622),'android-phone':(1080,1920),'ipad-13':(2064,2752)}
check('screenshot count',len(manifest['screenshots'])==18)
for item in manifest['screenshots']:
    path=OUT/item['path']; data=path.read_bytes()
    width,height,depth,color=struct.unpack('>IIBB',data[16:26])
    folder=path.parent.name
    check(item['path'],data[:8]==b'\x89PNG\r\n\x1a\n' and
          (width,height)==sizes[folder] and depth==8 and color==2 and
          hashlib.sha256(data).hexdigest()==item['sha256'],f'{width}×{height}; RGB, no alpha')
for name,size in [('vibra_app_icon_1024.png',(1024,1024)),
                  ('vibra_play_feature_graphic_1024x500.png',(1024,500)),
                  ('vibra_play_icon_512.png',(512,512))]:
    data=(OUT/'graphics'/name).read_bytes()
    width,height,depth,color=struct.unpack('>IIBB',data[16:26])
    check(name,(width,height)==size and depth==8 and color==2)

constants=(ROOT/'lib/core/constants/app_constants.dart').read_text()
try:
    release=json.loads(options.release_config.read_text())
    generated_defines=json.loads(options.defines_config.read_text())
except (OSError, ValueError):
    args.error('Private release configuration or app metadata is missing. '
               'Fill release/store-config.json and run script/release/app_config.py first.')
sys.path.insert(0, str(ROOT / 'script/release'))
from app_config import public_defines
try:
    expected_defines=public_defines(release)
except (ValueError, TypeError, AttributeError):
    args.error('Complete private release public metadata before checking materials.')
check('generated app metadata', generated_defines == expected_defines)
constant_defines = {'supportEmail':'VIBRA_SUPPORT_EMAIL', 'privacyEmail':'VIBRA_PRIVACY_EMAIL',
                   'legalEmail':'VIBRA_LEGAL_EMAIL', 'legalOwner':'VIBRA_LEGAL_OWNER',
                   'publicSiteUrl':'VIBRA_PUBLIC_SITE_URL', 'privacyUrl':'VIBRA_PRIVACY_URL',
                   'termsUrl':'VIBRA_TERMS_URL', 'supportUrl':'VIBRA_SUPPORT_URL',
                   'accountDeletionUrl':'VIBRA_ACCOUNT_DELETION_URL'}
for key, define in constant_defines.items():
    check(key + ' build-time metadata', bool(re.search(
        r'\b'+re.escape(key)+r'\s*=\s*String\.fromEnvironment\(\s*[\'\"]'+re.escape(define)+r'[\'\"]', constants)))
for key in ('legal_name', 'legal_address', 'support_email', 'privacy_email', 'legal_email'):
    check(key, bool(owner.get(key, '').strip()) and release.get(key) == owner[key])
check('public site app metadata', expected_defines.get('VIBRA_PUBLIC_SITE_URL') == owner['public_site_url'].rstrip('/'))
for key in ['privacy_url','terms_url','support_url','account_deletion_url']:
    check(key,release[key].startswith(owner['public_site_url']+'/'))
pending_owner_fields = [key for key in ('country', 'legal_address')
                        if not owner.get(key, '').strip()]
if owner.get('trader_status') not in ('trader', 'non_trader'):
    pending_owner_fields.append('trader_status')
if owner.get('mailbox_monitoring_status') != 'owner_confirmed':
    pending_owner_fields.append('mailbox_monitoring')
report={'scope':'store materials, not complete launch readiness','online':options.online,
        'checks':checks,'passed':all(item['passed'] for item in checks),
        'pending_owner_fields':pending_owner_fields,
        'questionnaires_submitted':False,'device_qa':False}
(OUT/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
for item in checks:
    if not item['passed']: print('FAIL '+item['check']+': '+item['detail'])
print(f"{sum(item['passed'] for item in checks)}/{len(checks)} material checks passed")
sys.exit(0 if report['passed'] else 1)
