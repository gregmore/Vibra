#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
platform="${1:-}"
if [[ "$platform" != android && "$platform" != ios ]]; then
  echo 'Usage: script/release/build_store_release.sh android|ios' >&2
  exit 2
fi
python3 script/security/prepare_client_env.py
python3 script/release/app_config.py
python3 script/release/preflight.py --platform "$platform" --online --report "release/preflight-$platform.json"
spotify_release_flag=$(python3 -c 'import json; print(str(json.load(open("release/store-config.json"))["spotify_enabled"]).lower())')
flutter clean
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub --dart-define-from-file=release/app-public-defines.json --dart-define=SPOTIFY_ENABLED="$spotify_release_flag"
mkdir -p release/symbols
if [[ "$platform" == android ]]; then
  flutter build appbundle --release --dart-define-from-file=release/app-public-defines.json --dart-define=SPOTIFY_ENABLED="$spotify_release_flag" --obfuscate --split-debug-info=release/symbols/android
  python3 script/security/scan_mobile_bundle.py build/app/outputs/bundle/release/app-release.aab
  python3 script/release/check_android_native.py build/app/outputs/bundle/release/app-release.aab
  cp build/app/outputs/bundle/release/app-release.aab release/vibra-android.aab
  mkdir -p release/symbols/android-r8
  cp build/app/outputs/mapping/release/mapping.txt release/symbols/android-r8/
else
  flutter build ipa --release --dart-define-from-file=release/app-public-defines.json --dart-define=SPOTIFY_ENABLED="$spotify_release_flag" --obfuscate --split-debug-info=release/symbols/ios --export-options-plist=ios/ExportOptions.plist
  python3 script/security/scan_mobile_bundle.py build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
  cp build/ios/ipa/*.ipa release/
fi
echo 'Store artifact prepared in release/. Keep symbols and signing material backed up.'
