#!/bin/bash
# SPDX-License-Identifier: MIT
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/module-cache"
export SWIFT_MODULECACHE_PATH="$PWD/.build/module-cache"
mkdir -p .build dist
app="$PWD/dist/Codex Accounts.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
/usr/bin/xcrun swiftc scripts/generate-icon.swift -o .build/generate-icon
.build/generate-icon .build/icon
cp .build/icon/AppIcon.png assets/AppIcon.png
cp .build/icon/AppIcon.icns "$app/Contents/Resources/"
for arch in arm64 x86_64; do
  /usr/bin/xcrun swiftc -O -target "$arch-apple-macosx13.0" \
    -framework AppKit -framework Security \
    Sources/ProfileStore.swift Sources/OfficialApp.swift Sources/main.swift -o ".build/accounts-$arch"
done
/usr/bin/lipo -create .build/accounts-arm64 .build/accounts-x86_64 -output "$app/Contents/MacOS/CodexAccounts"
cp packaging/Info.plist "$app/Contents/Info.plist"
cp README.md SECURITY.md LICENSE LICENSING.md THIRD_PARTY_NOTICES.md "$app/Contents/Resources/"
mkdir -p "$app/Contents/Resources/docs" "$app/Contents/Resources/assets"
cp docs/*.md "$app/Contents/Resources/docs/"
cp assets/*.png assets/*.svg "$app/Contents/Resources/assets/"
# Ad-hoc signature supports local preview; it is NOT a Developer ID signature.
/usr/bin/codesign --force --sign - "$app"
/usr/bin/codesign --verify --strict "$app"
/usr/bin/ditto --norsrc --noextattr -c -k --keepParent "$app" "dist/Codex-Accounts-preview-universal.zip"
(cd dist && /usr/bin/shasum -a 256 Codex-Accounts-preview-universal.zip > SHA256SUMS)
echo "Built universal macOS preview in dist/. Not notarized."
