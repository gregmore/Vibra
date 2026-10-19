#!/usr/bin/env python3
"""Check shipped catalogs and direct user-facing Dart literals.

Run from any folder. This deliberately leaves event/user content, proper names,
service identifiers and localized string composition alone; it does not claim to
be a full Dart AST or a substitute for visual QA in each language.
"""
import argparse
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
LOCALES = ('en', 'it', 'es', 'fr', 'de')
LITERAL = r"'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\""
TOKEN = re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|' + LITERAL)
VISIBLE_CONTEXT = re.compile(
    r'(?:\b(?:Text|SelectableText|Tab)\s*\(\s*|'
    r'\b(?:title|subtitle|label|hintText|tooltip|semanticsLabel|semanticLabel|'
    r'errorText|message|caption|eyebrow|actionLabel|secondaryActionLabel|text)\s*:\s*)$'
)
# Names and identifiers whose spelling is independent of the app language.
PROPER_NAMES = {'Vibra', 'Spotify', 'Google', 'Apple', 'OpenStreetMap',
                '© OpenStreetMap contributors', '© OpenStreetMap', 'Rock', 'Pop', 'Hip-Hop',
                'Rap', 'Jazz', 'Metal', 'Folk', 'Indie', 'R&B', 'Blues',
                'Classical', 'Dance', 'Punk', 'Reggae', 'Soul', 'Latin',
                'K-Pop', 'Techno', 'House', 'Country', '1', '9+', 'V', '0'}


def load_unique(path):
    def object_pairs(pairs):
        output = {}
        for key, value in pairs:
            if key in output:
                raise ValueError(f'Duplicate JSON key: {key}')
            output[key] = value
        return output
    return json.loads(path.read_text(), object_pairs_hook=object_pairs)


def audit():
    failures = []
    catalogs = {}
    for locale in LOCALES:
        path = ROOT / 'lib' / 'l10n' / f'app_{locale}.arb'
        try:
            catalogs[locale] = load_unique(path)
        except (ValueError, OSError) as error:
            failures.append(f'{path.relative_to(ROOT)}: {error}')
    if len(catalogs) != len(LOCALES):
        return {'passed': False, 'failures': failures}
    base_keys = {key for key in catalogs['en'] if not key.startswith('@')}
    for locale, catalog in catalogs.items():
        keys = {key for key in catalog if not key.startswith('@')}
        for key in sorted(base_keys - keys):
            failures.append(f'{locale}: missing {key}')
        for key in sorted(keys - base_keys):
            failures.append(f'{locale}: unexpected {key}')
        for key in sorted(base_keys & keys):
            value = catalog[key]
            if not isinstance(value, str) or not value.strip():
                failures.append(f'{locale}:{key}: empty/non-string message')
                continue
            if '\\n' in value:
                failures.append(f'{locale}:{key}: literal escaped newline')
            placeholders = catalog.get('@' + key, {}).get('placeholders', {})
            base_placeholders = catalogs['en'].get('@' + key, {}).get('placeholders', {})
            if placeholders != base_placeholders:
                failures.append(f'{locale}:{key}: placeholder metadata mismatch')
            declared = set(placeholders)
            used = set(re.findall(r'{([A-Za-z]\w*)\s*(?:}|,)', value))
            if used != declared:
                failures.append(f'{locale}:{key}: missing/unused placeholder metadata')
    hardcoded = []
    for path in sorted((ROOT / 'lib' / 'presentation').rglob('*.dart')):
        if 'providers' in path.parts:
            continue
        source = path.read_text()
        # Comments are lexical tokens and cannot turn an apostrophe in a
        # comment into a string spanning the subsequent Dart source.
        previous_end = 0
        clean_prefix = ''
        for token in TOKEN.finditer(source):
            raw = token.group()
            if raw.startswith('//') or raw.startswith('/*'):
                continue
            prefix = source[max(previous_end, token.start() - 220):token.start()]
            previous_end = token.end()
            if not VISIBLE_CONTEXT.search(prefix):
                continue
            value = raw[1:-1]
            if '$' in value or value in PROPER_NAMES or not re.search(r'[A-Za-zÀ-ÿ]', value):
                continue
            line = source.count('\n', 0, token.start()) + 1
            hardcoded.append({'file': str(path.relative_to(ROOT)), 'line': line, 'text': value})
    failures.extend(f"{row['file']}:{row['line']}: hardcoded UI: {row['text']}" for row in hardcoded)
    return {'passed': not failures, 'locales': list(LOCALES),
            'messages_per_locale': len(base_keys), 'hardcoded_ui': hardcoded,
            'failures': failures}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--json', action='store_true')
    args = parser.parse_args()
    result = audit()
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"Localization audit: {'PASS' if result['passed'] else 'FAIL'}")
        print(f"{result.get('messages_per_locale', 0)} messages × {len(LOCALES)} languages")
        for failure in result['failures']:
            print(failure)
    sys.exit(0 if result['passed'] else 1)


if __name__ == '__main__':
    main()
