#!/usr/bin/env python3
"""Package store screenshots and documents; requires Pillow, never credentials."""
import hashlib
import json
import plistlib
import zipfile
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
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
manifest = {'version': '1.0.0+2', 'capture_method': 'production Flutter widgets',
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
           'source': 'ios/Runner/PrivacyInfo.xcprivacy'}
(ROOT / 'store/questionnaires/apple-app-privacy.json').write_text(
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
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
    for folder in ['screenshots', 'graphics']:
        for path in sorted((OUT / folder).rglob('*.png')):
            z.write(path, path.relative_to(OUT))
    for name in ['screenshots.json', 'contact-sheet.jpg', 'verification.json']:
        if (OUT / name).exists(): z.write(OUT / name, name)
    for name in ['STORE_METADATA.md', 'PRIVACY_POLICY.md', 'TERMS_OF_SERVICE.md', 'SUPPORT.md']:
        z.write(ROOT / name, 'documents/' + name)
    z.write(ROOT / 'docs/store-materials-20261010.md', 'documents/verification-report.md')
    if (OUT / 'public-support.jpg').exists():
        z.write(OUT / 'public-support.jpg', 'preview/public-support.jpg')
    for path in sorted((ROOT / 'store/questionnaires').glob('*')):
        z.write(path, 'questionnaires/' + path.name)
    z.write(ROOT / 'store/README.md', 'README.md')
    z.write(ROOT / 'store/owner.json', 'owner.json')
print(f'Packaged {len(records)} screenshots: {archive}')
