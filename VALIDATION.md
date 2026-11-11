# Validation record — 0.1.0 preview

Performed on 2026-11-11, Apple Silicon macOS, Swift 6.2 toolchain.

- `bash scripts/test.sh`: 23 passing checks against temporary state.
- `.build/security-tests --check-installed-app` outside the execution sandbox: 24 passing checks, including strict verification of the installed official OpenAI app (`26.1103.60933`). The execution sandbox itself restricts signature resource access and can produce a misleading invalid-signature result; do not weaken production signature checks to work around sandbox diagnostics.
- `bash scripts/build.sh`: compiled arm64 and x86_64 at a macOS 13 deployment target, merged into a universal binary, ad-hoc signed, signature verified, ZIP and SHA-256 generated.
- Native UI: main window rendered, Add profile dialog opened and canceled, Privacy & security dialog opened and closed. No credentials entered and no existing accounts changed.
- Official-app launch arguments and unique profile homes are tested. Existing custom launchers were independently inspected before implementation; they are not imported by this project.

## Required before stable release

- Complete a fresh-profile sign-in, then a second distinct account sign-in, one at a time. Verify email/workspace in both official windows and confirm they can remain open together. Repeat opening each profile, restart both apps and macOS, and confirm persistent identity.
- Exercise personal, managed workspace/SSO, expired login, and browser account-selection behavior using authorized test accounts. This preview has no evidence for every domain/account type.
- Check backend state paths using non-secret process/path diagnostics. Do not collect environment dumps, tokens, authentication files, or private histories.
- Run on an Intel Mac and the oldest supported OS. Cross-compilation alone is not runtime compatibility validation.
- Complete Developer ID signing, notarization and stapling; verify a browser-downloaded package on a clean Mac with default Gatekeeper settings.
- Review source and release supply chain independently. No external security audit has been performed.

Until these are complete, retain the preview/prerelease label and do not promise universal account compatibility or frictionless installation.
