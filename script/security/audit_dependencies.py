"""Query OSV for resolved Pub, CocoaPods and pinned npm Edge dependencies."""
import json
import re
import urllib.request
from pathlib import Path
import yaml

root = Path(__file__).resolve().parents[2]
queries = []
lock = yaml.safe_load((root / 'pubspec.lock').read_text())
for name, package in lock['packages'].items():
    if package.get('source') == 'hosted':
        queries.append({'package': {'name': name, 'ecosystem': 'Pub'}, 'version': package['version']})
pods = root / 'ios/Podfile.lock'
if pods.exists():
    for line in pods.read_text().splitlines():
        match = re.match(r'^  - ([\w+.-]+) \(([^ )]+)\)', line)
        if match:
            queries.append({'package': {'name': match[1], 'ecosystem': 'CocoaPods'}, 'version': match[2]})
pins = set()
for p in (root / 'supabase/functions').rglob('*.ts'):
    pins.update(re.findall(r'esm.sh/(@[^/]+/[^@"\s]+)@([\d.]+)', p.read_text()))
pins.add(('imagescript', '1.3.0'))
for name, version in sorted(pins):
    queries.append({'package': {'name': name, 'ecosystem': 'npm'}, 'version': version})
queries = [q for q in queries if q['package']['ecosystem'] != 'CocoaPods']
request = urllib.request.Request('https://api.osv.dev/v1/querybatch',
    data=json.dumps({'queries': queries}).encode(), headers={'Content-Type':'application/json'})
with urllib.request.urlopen(request, timeout=90) as response:
    results = json.load(response)['results']
output = {'packages_checked': len(queries), 'findings': [dict(query=q, **r) for q,r in zip(queries,results) if r.get('vulns')],
    'limitations': 'Known OSV entries only; CocoaPods, native Gradle and unpinned remote/transitive Edge imports not covered.'}
print(json.dumps(output, indent=2))
