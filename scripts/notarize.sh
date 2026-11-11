#!/bin/bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
: "${DEVELOPER_ID:?Set DEVELOPER_ID to your Developer ID Application identity}"
: "${NOTARY_PROFILE:?Set NOTARY_PROFILE to an existing notarytool keychain profile}"
app="$PWD/dist/Codex Accounts.app"
test -d "$app"
/usr/bin/codesign --force --options runtime --timestamp --sign "$DEVELOPER_ID" "$app"
/usr/bin/codesign --verify --strict "$app"
/usr/bin/ditto --norsrc --noextattr -c -k --keepParent "$app" dist/notary-upload.zip
/usr/bin/xcrun notarytool submit dist/notary-upload.zip --keychain-profile "$NOTARY_PROFILE" --wait
/usr/bin/xcrun stapler staple "$app"
/usr/bin/xcrun stapler validate "$app"
/usr/sbin/spctl --assess --type execute --verbose "$app"
/usr/bin/ditto --norsrc --noextattr -c -k --keepParent "$app" dist/Codex-Accounts-universal.zip
(cd dist && /usr/bin/shasum -a 256 Codex-Accounts-universal.zip > SHA256SUMS-notarized)
echo "Notarized package ready. Publish only after testing this downloaded package on a clean Mac."
