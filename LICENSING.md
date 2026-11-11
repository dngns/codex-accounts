# Licensing, artwork provenance, and trademarks

Reviewed: 2026-11-11. Scope: the files tracked by this repository and the app archive built by `scripts/build.sh`. This is a source and packaging review, not a legal opinion, independent audit, or worldwide trademark clearance.

## Project license

The [MIT license](LICENSE) applies to the project's code, scripts, documentation, and original icon assets, to the extent copyright or other licensable rights exist. The project copyright notice identifies `dngns and contributors`. The standard MIT permission and warranty terms are unchanged. Redistribution must preserve the applicable copyright and license notices. MIT permits commercial use, modification, and redistribution under its terms.

This project was developed with AI assistance. We do not claim that AI-assisted output is necessarily copyrightable in every jurisdiction, or that a generated design can be proven globally unique. The license grants only rights that the project contributors can grant. It does not cover third-party trademarks, the official Codex application, or Apple software.

## Icon provenance

The icon was designed specifically for this repository in this development session. Its complete construction is in `scripts/generate-icon.swift`: rounded rectangles, circles, a background gradient, and project-selected colors. The same shape coordinates produce the SVG and raster representations. There are no reference images, downloaded graphics, stock images, SF Symbols, third-party icon packs, embedded fonts, or OpenAI/ChatGPT logos in the artwork.

| File | Origin | License / use |
| --- | --- | --- |
| `scripts/generate-icon.swift` | Project-specific drawing code, AI-assisted | MIT |
| `assets/AppIcon.svg` | Generated editable geometry from that script | MIT where applicable |
| `assets/AppIcon.png` | Generated 1024px preview from that script | MIT where applicable |
| `AppIcon.icns` in the app | Generated PNG representations packaged by Apple's `iconutil` | Same project-artwork license; no Apple artwork included |

To regenerate the assets, run `bash scripts/build.sh`, then copy `.build/icon/AppIcon.svg` and `.build/icon/AppIcon.png` into `assets/`. Do not copy an icon from the official app or another project. The build also verifies that the committed SVG matches the generator.

## Dependencies and redistribution

The app uses Apple system frameworks and the system Swift runtime. It does not bundle the official Codex app, an SDK, a font, a third-party package, or a copied third-party implementation. The CI checkout action is build tooling referenced by commit, not bundled in this application. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the inventory and upstream terms.

The build packages `LICENSE`, this document, `THIRD_PARTY_NOTICES.md`, `README.md`, and `SECURITY.md` alongside the app's own icon and executable. Future dependencies or assets must be reviewed before inclusion; adding a repository-level MIT file does not relicense someone else's material.

## Names and trademarks

The name **Codex Accounts** is retained at the maintainer's request. **Codex**, **OpenAI**, and **ChatGPT** identify the third-party product with which this launcher is intended to work; they are not this project's trademarks to license. The independent-project notice appears in the README, app interface, About metadata, and license dialog. The icon uses this project's own geometry rather than OpenAI's marks or visual assets. The launcher does not claim to be an official OpenAI product or imply endorsement.

MIT is a copyright license, not permission to use OpenAI's or Apple's trademarks. OpenAI's published brand guidelines prohibit confusing sponsorship/endorsement and incorporating its logo into one's own branding. This review does not establish that the retained product name is approved or that all trademark questions are resolved. If the name receives an objection or creates confusion, adopt a distinct product name and update the distribution metadata. Do not describe this project as “official,” “approved,” or “guaranteed free of infringement.”

## Review findings and limits

- Reviewed the tracked Swift code, shell scripts, workflow, metadata, documents, and new artwork generator for external imports, assets, and license declarations.
- No vendored third-party source, external artwork, font files, or package dependency manifests were found in the reviewed tree.
- Updated the MIT copyright holder, added SPDX identifiers to source/build files, and made icon licensing and attribution explicit.
- The published app can be checked for the icon and required notices without collecting any account data.
- No patent search, global trademark search, independent similarity analysis, or review of every compiler-emitted instruction was performed. This is not an absolute non-infringement guarantee.

## Primary references

- [Open Source Initiative: MIT license](https://opensource.org/license/mit)
- [OpenAI: brand guidelines](https://openai.com/brand/)
- [actions/checkout: license at the pinned commit](https://github.com/actions/checkout/blob/11bd71901bbe5b1630ceea73d27597364c9af683/LICENSE)
