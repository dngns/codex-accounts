# Validation record — 0.1.0 preview

## 0.1.1 icon and licensing update — 2026-11-11

- Retained the product name and all existing profile paths. Added an original geometric icon generator, editable SVG, PNG preview, and the bundle's `CFBundleIconFile` entry; no external artwork, font, or symbol library was used.
- Visually inspected the generated 1024px PNG. The build creates the standard ten PNG iconset representations and packages them as ICNS; the committed SVG must match the generator output.
- Updated MIT attribution, source SPDX identifiers, licensing/provenance and third-party inventory documents. Those notices are included in the app bundle; the interface also explicitly states its independence from OpenAI.
- Existing automated isolation/security checks remain at 23 passing checks. Rebuilt the universal app with the icon and verified its ad-hoc signature. Apple `iconutil` requires execution outside this task's restricted sandbox on the local machine.
- Inspected bundle metadata (`0.1.1`, `AppIcon.icns`), all ten PNG dimensions and ICNS chunk lengths. Confirmed all five bundled license/security documents exactly match source and the ZIP includes the icon without resource-fork sidecar metadata. `otool -L` shows system framework/runtime paths only for both architectures.
- No account sign-ins or changes to authentication/profile data were made for this update. The new About/license UI compiles; its interactive behavior is not part of the earlier 0.1.0 UI acceptance record below.

## 0.1.0 baseline

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
