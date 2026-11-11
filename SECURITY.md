# Security policy and threat model

## What runs

The runtime consists of `Sources/ProfileStore.swift`, `Sources/OfficialApp.swift`, and `Sources/main.swift`. It uses Foundation, AppKit, Security, and Darwin system APIs. No third-party libraries, server, HTTP client, web view, telemetry, updater, password input, OAuth callback handler, or credential parser is included.

The launcher writes only its labels, lock file, private directory structure, and an initial `config.toml` selecting file credential storage. It starts the official app via `/usr/bin/open`; the official app and the system browser perform sign-in, account refresh, and all service requests. No token is passed as a command argument.

## Protections

- Random UUID directory names; display names never become paths or shell commands.
- Argument arrays, no shell evaluation.
- Private `0700` directories and `0600` launcher-created files; existing unsafe owners, permissions, symbolic links, and hardlinked regular files are rejected at checked locations.
- `O_NOFOLLOW` metadata access, exclusive new-file creation, atomic label replacement, and a label lock for concurrent add operations.
- A small allowlist environment is passed to the `open` subprocess, excluding the launcher's inherited API keys, proxies, endpoint overrides, and library injection variables. LaunchServices/system or official-app configuration is outside this guarantee.
- Official app validation uses Apple's static signature verification, strict validation of all architectures, and an Apple trust anchor plus bundle identifier and pinned developer team. An unsigned or tampered app is rejected.
- No import of existing authentication, no default-profile mutation, no token display, no destructive profile deletion, and no automatic downloads or updates.

## Limits — do not promise absolute safety

The launcher is not App Sandbox isolated: it must create folders outside an app container and launch another app with explicit paths. No Accessibility, Full Disk Access, administrator privileges, or browser permissions are requested. Its lack of networking is an auditable code property, not a kernel-enforced egress block.

Separate directories are not separate macOS users. Software running as the same user (including a malicious future launcher build) can read private files. Root, malware, backups, synced directories, and physical access can expose them too. The official app may store plaintext credentials, browser sessions, history, and other sensitive data. The launcher never reads these files, but cannot make them inaccessible to other same-user software. Directory checks reduce accidental misuse and link attacks; they do not defend against an active same-user attacker replacing parent directories during operation.

We do not claim a third-party security audit, complete independence of every official backend, successful concurrent login for every account type, or future desktop compatibility. Managed authentication requirements still apply. Verify the email/workspace in the official window; profile labels are not proof of identity. OAuth port contention and browser account selection can affect simultaneous login; sign in to new profiles one at a time.

Ad-hoc signing is not publisher authentication. The initial preview is not notarized. Do not disable macOS protections to run it. Production distribution requires Developer ID signing, successful Apple notarization/stapling, and a clean-machine download test. Notarization checks for known malicious content, not correctness or a full security audit.

## Verify a release

1. Check the repository, tag, commit, build workflow, source, and changes before trusting a binary.
2. Compare the ZIP's `shasum -a 256` with `SHA256SUMS`. This alone is not identity verification.
3. Inspect the app using `codesign --verify --strict --verbose=2 'Codex Accounts.app'` and `codesign -dv --verbose=4 'Codex Accounts.app'`.
4. For a future notarized release, also use `spctl --assess --type execute --verbose=4 'Codex Accounts.app'` and `xcrun stapler validate 'Codex Accounts.app'`.
5. Build from a reviewed source commit if you prefer. Compilers and signing timestamps mean independent binaries need not have identical hashes.

## Report a vulnerability

Use the repository's private GitHub vulnerability reporting feature when available. If unavailable, open an issue requesting a private contact channel **without publishing exploit details, account information, logs, screenshots containing secrets, tokens, or profile directories**. No account data is needed to report a launcher bug. Only the latest release is maintained in this early-stage project.
