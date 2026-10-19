#!/bin/sh
set -eu

# The local Flutter SDK preserves the stub binary's signing identifier (App).
# Sign the complete framework using its plist identifier before device install.
case "${CONFIGURATION:-}" in
  Debug*) ;;
  *) exit 0 ;;
esac
[ "${PLATFORM_NAME:-}" = "iphoneos" ] || exit 0
[ "${CODE_SIGNING_ALLOWED:-YES}" != "NO" ] || exit 0
[ -n "${EXPANDED_CODE_SIGN_IDENTITY:-}" ] || exit 0

framework="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/App.framework"
identifier=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$framework/Info.plist")
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" \
  --identifier "$identifier" --timestamp=none "$framework"
