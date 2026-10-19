#!/usr/bin/env python3
"""Inspect the Git index for private files and credentials without printing values."""
import base64
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PRIVATE_NAMES = {'.env', '.env.public', 'key.properties', 'google-services.json',
                 'GoogleService-Info.plist', 'Signing.local.xcconfig'}
PRIVATE_SUFFIXES = {'.p12', '.p8', '.jks', '.keystore', '.mobileprovision', '.pfx',
                    '.pem', '.key', '.ipa', '.apk', '.aab', '.sqlite', '.sqlite3'}
PRIVATE_PREFIXES = ('release/', 'build/', 'build.nosync/', 'android/build/',
                    'supabase/.temp/', 'supabase/.branches/', 'store/site/dist/',
                    'store/site/.openai/')
PATTERNS = {
    'private_key': re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----\s+[A-Za-z0-9+/=\s]{40,}'),
    'github_token': re.compile(r'\bgh[pousr]_[A-Za-z0-9]{30,}\b|\bgithub_pat_[A-Za-z0-9_]{50,}\b'),
    'supabase_secret_key': re.compile(r'\bsb_secret_[A-Za-z0-9_-]{24,}\b'),
    'aws_access_key': re.compile(r'\b(?:AKIA|ASIA)[A-Z0-9]{16}\b'),
}
JWT = re.compile(r'\beyJ[A-Za-z0-9_-]+\.([A-Za-z0-9_-]+)\.[A-Za-z0-9_-]{15,}\b')
HOME = re.compile(r'(?<![A-Za-z0-9_/])(?:file://)?/(?:Users|home)/([A-Za-z0-9_.-]+)')


def private_values():
    values = set()
    for file in (ROOT / 'store/owner.json', ROOT / 'release/store-config.json'):
        try:
            config = json.loads(file.read_text())
            for key in ('legal_name', 'legal_address', 'support_email', 'privacy_email', 'legal_email'):
                value = config.get(key, '')
                if isinstance(value, str) and len(value) >= 8 and '{{' not in value and 'example.com' not in value:
                    values.add(value)
        except (OSError, ValueError, AttributeError):
            pass
    return values


def main():
    files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
    known = private_values()
    findings = []
    checked = 0
    for name in files:
        if not name:
            continue
        path = Path(name)
        if (path.name in PRIVATE_NAMES or path.suffix.lower() in PRIVATE_SUFFIXES or
                name.startswith(PRIVATE_PREFIXES) or name in ('store/owner.json', 'store/owner.local.json') or
                path.name.startswith('service-account') and path.suffix == '.json'):
            findings.append({'path': name, 'category': 'private_file'})
            continue
        blob = subprocess.run(['git', 'show', ':' + name], cwd=ROOT, capture_output=True)
        if blob.returncode:
            findings.append({'path': name, 'category': 'unreadable_index_entry'})
            continue
        checked += 1
        # Secrets embedded in binary assets are also checked. No content is logged.
        text = blob.stdout.decode('utf-8', errors='ignore')
        for category, pattern in PATTERNS.items():
            match = pattern.search(text)
            if match:
                findings.append({'path': name, 'category': category,
                                 'line': text.count('\n', 0, match.start()) + 1})
        for match in JWT.finditer(text):
            try:
                encoded = match.group(1)
                payload = json.loads(base64.urlsafe_b64decode(encoded + '=' * (-len(encoded) % 4)))
                if payload.get('role') in ('service_role', 'supabase_admin'):
                    findings.append({'path': name, 'category': 'privileged_jwt',
                                     'line': text.count('\n', 0, match.start()) + 1})
            except (ValueError, UnicodeError, AttributeError):
                pass
        for match in HOME.finditer(text):
            if match.group(1) not in {'runner', 'user', 'example', 'USERNAME'}:
                findings.append({'path': name, 'category': 'personal_home_path',
                                 'line': text.count('\n', 0, match.start()) + 1})
                break
        if any(value in text for value in known):
            findings.append({'path': name, 'category': 'local_owner_data'})
    print(json.dumps({'scope': 'Git index only; existing remote history is unchanged',
                      'files_checked': checked, 'passed': not findings, 'findings': findings}, indent=2))
    return 1 if findings else 0


if __name__ == '__main__':
    sys.exit(main())
