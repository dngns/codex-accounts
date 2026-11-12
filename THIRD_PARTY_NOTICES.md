# Third-party components and boundaries

Inventory reviewed: 2026-11-12.

| Component | How used | Included in downloaded app? | License boundary |
| --- | --- | --- | --- |
| Foundation, AppKit, Security, Darwin | Apple-provided system APIs | Frameworks are dynamically linked, not copied into the bundle | Apple platform terms; not relicensed by this project |
| CryptoKit | Apple framework used by the build-time icon packager for source hash verification | Not copied; not used by the app runtime | Apple platform terms |
| Swift runtime and compiler | Compile project source; system runtime linkage | No separate Swift runtime package is copied into the bundle | Upstream toolchain/platform terms remain applicable |
| `/usr/bin/open`, `iconutil`, `codesign`, `ditto`, `lipo` | Existing macOS launch/build/packaging tools | Tools are not redistributed | Apple platform terms |
| `actions/checkout` at `11bd71901bbe5b1630ceea73d27597364c9af683` | GitHub Actions checkout step | No; only referenced by the workflow | MIT, Copyright (c) 2018 GitHub, Inc. and contributors; [upstream full license](https://github.com/actions/checkout/blob/11bd71901bbe5b1630ceea73d27597364c9af683/LICENSE) |
| Official Codex desktop app | Installed separately by the user; validated and launched | No executable, logo, SDK, or source from that app is bundled | OpenAI's own terms and trademarks, outside this project's MIT grant |

The approved icon is AI-generated with the built-in OpenAI imagegen tool from a text-only brief; its exact source PNG is committed. No reference image or official brand asset was supplied. See `LICENSING.md` and `docs/ICON.md` for the provenance, prompt, source hash and license limits. The UI uses the macOS system font through system APIs; no font file is shipped. No third-party image, icon library, package manager dependency, or OpenAI logo is included in the current app archive.

This inventory is not an attempt to apply the project MIT license to Apple/OpenAI software or other third-party rights. Before adding or redistributing a new component, review its actual license, transitive dependencies, attribution and notice requirements, and trademark restrictions.
