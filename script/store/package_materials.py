#!/usr/bin/env python3
"""Package store screenshots and documents; requires Pillow, never credentials."""
import argparse
import hashlib
import json
import os
import plistlib
import re
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--owner-config', type=Path,
                    default=Path(os.environ.get('VIBRA_OWNER_CONFIG', str(ROOT / 'store/owner.json'))),
                    help='Private owner JSON (default: store/owner.json or VIBRA_OWNER_CONFIG)')
parser.add_argument('--documents-dir', type=Path, default=ROOT / 'release/store-documents')
options = parser.parse_args()
try:
    owner_bytes = options.owner_config.read_bytes()
    owner = json.loads(owner_bytes)
except FileNotFoundError:
    parser.error('Owner configuration is missing. Copy store/owner.example.json '
                 'to ignored store/owner.json and fill it, or pass --owner-config.')
except (OSError, ValueError):
    parser.error('Unable to read owner configuration as a JSON object.')
if not isinstance(owner, dict):
    parser.error('Owner configuration must be a JSON object.')

# A successful example build or stale legal copy must never become a release ZIP.
documents = options.documents_dir
try:
    generation = json.loads((documents / 'generation.json').read_text())
except (OSError, ValueError):
    parser.error('Personalized legal documents are missing. Run build_site.py '
                 'with the same private --owner-config before packaging.')
if (not isinstance(generation, dict) or not isinstance(generation.get('documents'), dict)
        or generation.get('example_mode') is not False
        or generation.get('owner_config_sha256') != hashlib.sha256(owner_bytes).hexdigest()):
    parser.error('Legal documents are an example or use another owner configuration. '
                 'Regenerate them with the private owner configuration.')
document_names = ('STORE_METADATA.md', 'PRIVACY_POLICY.md', 'TERMS_OF_SERVICE.md', 'SUPPORT.md')
for document_name in document_names:
    try:
        contents = (documents / document_name).read_bytes()
    except OSError:
        parser.error('A personalized legal/listing document is missing. Run build_site.py first.')
    if (hashlib.sha256(contents).hexdigest() != generation.get('documents', {}).get(document_name)
            or re.search(rb'YOUR_|PLACEHOLDER|\{\{[A-Z_]+\}\}|@(?:[\w.-]+\.)?example\.(?:com|org|net)\b', contents, re.I)):
        parser.error('Personalized legal/listing documents are stale or contain placeholders. '
                     'Complete the private configuration and regenerate them.')

def personalized_copy(path):
    """Resolve public repository tokens only inside the private store archive."""
    contents = path.read_text()
    for token, field in {'LEGAL_NAME':'legal_name', 'LEGAL_ADDRESS':'legal_address',
                         'SUPPORT_EMAIL':'support_email', 'PRIVACY_EMAIL':'privacy_email',
                         'LEGAL_EMAIL':'legal_email', 'PUBLIC_SITE_URL':'public_site_url'}.items():
        contents = contents.replace('{{' + token + '}}', owner.get(field, ''))
    contents = re.sub(r'^> Modello pubblico:[^\n]*\n\n', '', contents)
    if re.search(r'\{\{[A-Z_]+\}\}', contents):
        parser.error('A store document contains unresolved owner tokens. Complete its private configuration.')
    return contents

try:
    from PIL import Image, ImageDraw
except ImportError:
    parser.error('Pillow is required to package screenshots. Use a Python environment with Pillow installed.')


def read_app_version(pubspec):
    matches = re.findall(r'^version:\s*([^\r\n#]+)', pubspec.read_text(), re.M)
    if len(matches) != 1:
        raise SystemExit('pubspec.yaml: expected exactly one app version')
    version = matches[0].strip().strip('\'"')
    if not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?\+\d+', version):
        raise SystemExit('pubspec.yaml: expected version name and build number')
    return version


APP_VERSION = read_app_version(ROOT / 'pubspec.yaml')
OUT = ROOT / 'release/store-materials'
OUT.mkdir(parents=True, exist_ok=True)
formats = {'ios-medium': (1206, 2622), 'android-phone': (1080, 1920),
           'ipad-13': (2064, 2752)}
records = []
for folder, size in formats.items():
    files = sorted((OUT / 'screenshots' / folder).glob('*.png'))
    if len(files) != 6:
        raise SystemExit(f'{folder}: expected 6 captures, found {len(files)}')
    for path in files:
        with Image.open(path) as source:
            if source.size != size:
                raise SystemExit(f'{path.name}: invalid dimensions {source.size}')
            # Remove the encoding's alpha channel without changing UI content.
            rgb = source.convert('RGB')
            rgb.save(path, optimize=True)
        records.append({'path': str(path.relative_to(OUT)), 'width': size[0],
                        'height': size[1], 'mode': 'RGB',
                        'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
manifest = {'version': APP_VERSION, 'capture_method': 'production Flutter widgets',
            'fixture_data': 'fictional, local, no backend writes',
            'device_qa': False, 'screenshots': records}
(OUT / 'screenshots.json').write_text(json.dumps(manifest, indent=2) + '\n')

# Compact visual index, not a store screenshot.
sheet = Image.new('RGB', (1236, 482), '#eeeaf3')
draw = ImageDraw.Draw(sheet)
for i, path in enumerate(sorted((OUT / 'screenshots/ios-medium').glob('*.png'))):
    with Image.open(path) as source:
        thumbnail = source.copy()
        thumbnail.thumbnail((194, 438))
        sheet.paste(thumbnail, (12 + i * 204, 32))
    draw.text((12 + i * 204, 10), path.stem, fill='#20182d')
sheet.save(OUT / 'contact-sheet.jpg', quality=94)

manifest_ios = plistlib.loads((ROOT / 'ios/Runner/PrivacyInfo.xcprivacy').read_bytes())
privacy = {'status': 'proposed_from_code_not_submitted',
           'collected_data': manifest_ios['NSPrivacyCollectedDataTypes'],
           'tracking': manifest_ios['NSPrivacyTracking'],
           'source': 'ios/Runner/PrivacyInfo.xcprivacy',
           'current_release_features': owner.get('feature_availability', {}),
           'spotify_data_scope': 'Only preexisting connections remain relevant; '
               'revocation and deletion retained. Verify existing backend sync '
               'jobs before declaring that no new Spotify data flows occur.'}
(OUT / 'apple-app-privacy.json').write_text(
    json.dumps(privacy, indent=2) + '\n')

assets = OUT / 'graphics'
assets.mkdir(exist_ok=True)
for name in ['vibra_play_feature_graphic_1024x500.png', 'vibra_app_icon_1024.png']:
    with Image.open(ROOT / 'assets/branding/raster' / name) as source:
        source.convert('RGB').save(assets / name, optimize=True)
with Image.open(assets / 'vibra_app_icon_1024.png') as source:
    source.resize((512, 512), Image.Resampling.LANCZOS).save(
        assets / 'vibra_play_icon_512.png')

# Explicit allowlist: no release configuration, .env, Git metadata or font cache.
archive = OUT / 'vibra-store-materials.zip'
archive_text = {
    'documents/materials-history-20261010.md': personalized_copy(ROOT / 'docs/store-materials-20261010.md'),
    'documents/verification-report.md': personalized_copy(ROOT / 'docs/bugfixes-20261015.md'),
    'README.md': personalized_copy(ROOT / 'store/README.md'),
}
questionnaire_files = []
for path in sorted((ROOT / 'store/questionnaires').glob('*')):
    source = OUT / path.name if path.name == 'apple-app-privacy.json' else path
    if source.suffix in ('.md', '.json'):
        archive_text['questionnaires/' + path.name] = personalized_copy(source)
    else:
        questionnaire_files.append(source)

# Commit the archive only after every personalized source has been validated.
with tempfile.NamedTemporaryFile(dir=OUT, prefix='.vibra-store-', suffix='.zip', delete=False) as pending:
    pending_path = Path(pending.name)
try:
    with zipfile.ZipFile(pending_path, 'w', zipfile.ZIP_DEFLATED) as z:
        for folder in ['screenshots', 'graphics']:
            for path in sorted((OUT / folder).rglob('*.png')):
                z.write(path, path.relative_to(OUT))
        for name in ['screenshots.json', 'contact-sheet.jpg', 'verification.json']:
            if (OUT / name).exists(): z.write(OUT / name, name)
        for name in document_names:
            z.write(documents / name, 'documents/' + name)
        if (OUT / 'public-support.jpg').exists():
            z.write(OUT / 'public-support.jpg', 'preview/public-support.jpg')
        for name, contents in archive_text.items():
            z.writestr(name, contents)
        for path in questionnaire_files:
            z.write(path, 'questionnaires/' + path.name)
        z.writestr('owner.json', owner_bytes)
    pending_path.replace(archive)
finally:
    pending_path.unlink(missing_ok=True)
print(f'Packaged {len(records)} screenshots: {archive}')
