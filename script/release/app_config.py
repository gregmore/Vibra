#!/usr/bin/env python3
"""Write allowlisted public app metadata from a private release configuration."""
import argparse
import json
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[2]
FIELDS = {
    'VIBRA_SUPPORT_EMAIL': 'support_email',
    'VIBRA_PRIVACY_EMAIL': 'privacy_email',
    'VIBRA_LEGAL_EMAIL': 'legal_email',
    'VIBRA_LEGAL_OWNER': 'legal_name',
    'VIBRA_PRIVACY_URL': 'privacy_url',
    'VIBRA_TERMS_URL': 'terms_url',
    'VIBRA_SUPPORT_URL': 'support_url',
    'VIBRA_ACCOUNT_DELETION_URL': 'account_deletion_url',
}


def public_defines(config):
    result = {define: str(config.get(field, '')).strip()
              for define, field in FIELDS.items()}
    result['VIBRA_PUBLIC_SITE_URL'] = str(config.get('public_site_url') or
        result['VIBRA_PRIVACY_URL'].rsplit('/', 1)[0]).rstrip('/')
    for name, value in result.items():
        if not value or any(marker in value.lower() for marker in ('example.com', 'your_', 'placeholder')):
            raise ValueError('Missing configured public app metadata: ' + name)
        if name.endswith('_URL'):
            url = urlsplit(value)
            if url.scheme != 'https' or not url.hostname:
                raise ValueError('Public app links must use HTTPS: ' + name)
    # Deliberate allowlist: no address, key, token, password, or arbitrary config.
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path, default=ROOT / 'release/store-config.json')
    parser.add_argument('--output', type=Path, default=ROOT / 'release/app-public-defines.json')
    args = parser.parse_args()
    try:
        result = public_defines(json.loads(args.config.read_text()))
    except (OSError, ValueError, TypeError, AttributeError) as error:
        raise SystemExit('Configure private release/store-config.json before generating release metadata (' + type(error).__name__ + ')')
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print('Generated allowlisted public app metadata; no values printed')


if __name__ == '__main__':
    main()
