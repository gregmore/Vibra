#!/usr/bin/env python3
"""Validate listing limits, PNG dimensions, links and public unauthenticated pages."""
import argparse
import hashlib
from html.parser import HTMLParser
import json
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
options = args.parse_args()
owner = json.loads((ROOT / 'store/owner.json').read_text())
checks = []
def check(name, passed, detail=''):
    checks.append({'check': name, 'passed': bool(passed), 'detail': detail})

metadata = (ROOT / 'STORE_METADATA.md').read_text()
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
for path in sorted(site.glob('*.html')):
    source=path.read_text(); parser=Links(); parser.feed(source)
    check(f'{path.name} heading',parser.headings==1)
    check(f'{path.name} email',owner['support_email'] in source)
    check(f'{path.name} no placeholders',not re.search(r'@vibra\.app|INSERT|YOUR_|TODO|PLACEHOLDER',source))
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

manifest=json.loads((OUT/'screenshots.json').read_text())
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
for key in ['supportEmail','privacyEmail','legalEmail']:
    check(key,f"{key} = '{owner['support_email']}'" in constants)
release=json.loads((ROOT/'release/store-config.json').read_text())
for key in ['privacy_url','terms_url','support_url','account_deletion_url']:
    check(key,release[key].startswith(owner['public_site_url']+'/'))
report={'scope':'store materials, not complete launch readiness','online':options.online,
        'checks':checks,'passed':all(item['passed'] for item in checks),
        'pending_owner_fields':['country','legal_address','trader_status','mailbox_monitoring'],
        'questionnaires_submitted':False,'device_qa':False}
(OUT/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
for item in checks:
    if not item['passed']: print('FAIL '+item['check']+': '+item['detail'])
print(f"{sum(item['passed'] for item in checks)}/{len(checks)} material checks passed")
sys.exit(0 if report['passed'] else 1)
