#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/module-cache"
export SWIFT_MODULECACHE_PATH="$PWD/.build/module-cache"
mkdir -p .build
/usr/bin/xcrun swiftc -framework Security Sources/ProfileStore.swift Sources/OfficialApp.swift Tests/main.swift -o .build/security-tests
.build/security-tests "$@"
