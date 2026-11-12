# Licensing, artwork provenance, and trademarks

Reviewed: 2026-11-12. Scope: the files tracked by this repository and the app archive built by `scripts/build.sh`. This is a source and packaging review, not a legal opinion, independent audit, or worldwide trademark clearance.

## Project license

The [MIT license](LICENSE) applies to the project's code, scripts, documentation, and original icon assets, to the extent copyright or other licensable rights exist. The project copyright notice identifies `dngns and contributors`. The standard MIT permission and warranty terms are unchanged. Redistribution must preserve the applicable copyright and license notices. MIT permits commercial use, modification, and redistribution under its terms.

This project was developed with AI assistance. We do not claim that AI-assisted output is necessarily copyrightable in every jurisdiction, or that a generated design can be proven globally unique. The license grants only rights that the project contributors can grant. It does not cover third-party trademarks, the official Codex application, or Apple software.

## Icon provenance

The current icon is the **double-C raster concept approved by the maintainer on 2026-11-12**. It was created using the built-in OpenAI imagegen tool from a text-only project brief; no reference image, stock image, icon pack, font file, or official logo was supplied as input. This is AI-generated artwork, not a hand-drawn vector. It has not received independent similarity or trademark clearance.

| File | Origin | License / use |
| --- | --- | --- |
| `assets/AppIcon-source.png` | Exact approved imagegen output, 1254×1254 RGBA | Project MIT grant where rights exist and can be granted |
| `assets/AppIcon.png` | Approved image scaled and centered for the app-icon canvas | Same artwork grant |
| `scripts/generate-icon.swift` | Project-authored packaging code; verifies the source hash and creates PNG sizes / ICNS | MIT |
| `AppIcon.icns` in the app | Approved raster artwork packaged by Apple's `iconutil` | Same artwork grant; no Apple artwork copied |
| `assets/showcase.png`, `assets/quickstart.png` | Source-derived offscreen native UI render with fixture labels and project-authored composition | MIT where applicable; see `docs/SHOWCASE.md` |
| Download/button badge SVGs in `assets/` | Project-authored geometric/text graphics | MIT where applicable |

See [the approved icon's prompt and source hash](docs/ICON.md). `assets/AppIcon-source.png` is preserved byte-for-byte. The packager scales and centers it with a consistent margin and clips stray outer pixels to the rounded tile; it does not redraw or recolor the monogram. The current icon has no editable vector master. The earlier geometric SVG is retained in historical Git tags, not passed off as the source of the approved raster artwork.

To package the approved artwork, run `bash scripts/build.sh`. The source image is pinned by SHA-256 so the build will fail if it is replaced without a deliberate review. No image-generation API or network call is made during the build. The source PNG is sufficient to reproduce the packaged size variants; model regeneration is not expected to reproduce the same image.

## Dependencies and redistribution

The app uses Apple system frameworks and the system Swift runtime. It does not bundle the official Codex app, an SDK, a font, a third-party package, or a copied third-party implementation. The CI checkout action is build tooling referenced by commit, not bundled in this application. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for the inventory and upstream terms.

The build packages `LICENSE`, this document, `THIRD_PARTY_NOTICES.md`, `README.md`, and `SECURITY.md` alongside the app's own icon and executable. Supporting `docs/` and project-authored `assets/` are included so the bundled README's local visuals and guides resolve. The live build badge is a URL to GitHub's service; its graphic is not vendored. Future dependencies or assets must be reviewed before inclusion; adding a repository-level MIT file does not relicense someone else's material.

## Names and trademarks

The name **Codex Accounts** is retained at the maintainer's request. **Codex**, **OpenAI**, and **ChatGPT** identify the third-party product with which this launcher is intended to work; they are not this project's trademarks to license. The independent-project notice appears in the README, app interface, About metadata, and license dialog. The brief requested an independent double-C monogram and excluded OpenAI/ChatGPT logos; no official brand asset was supplied. The launcher does not claim to be an official OpenAI product or imply endorsement.

MIT is a copyright license, not permission to use OpenAI's or Apple's trademarks. OpenAI's published brand guidelines prohibit confusing sponsorship/endorsement and incorporating its logo into one's own branding. This review does not establish that the retained product name is approved or that all trademark questions are resolved. If the name receives an objection or creates confusion, adopt a distinct product name and update the distribution metadata. Do not describe this project as “official,” “approved,” or “guaranteed free of infringement.”

## Review findings and limits

- Reviewed the tracked Swift code, shell scripts, workflow, metadata, documents, and new artwork generator for external imports, assets, and license declarations.
- No vendored third-party source, stock artwork, font files, or package dependency manifests were found in the reviewed tree. The imagegen-origin icon is explicitly documented above.
- Updated the MIT copyright holder, added SPDX identifiers to source/build files, and made icon licensing and attribution explicit.
- The published app can be checked for the icon and required notices without collecting any account data.
- No patent search, global trademark search, independent similarity analysis, or review of every compiler-emitted instruction was performed. This is not an absolute non-infringement guarantee.

## Primary references

- [Open Source Initiative: MIT license](https://opensource.org/license/mit)
- [OpenAI: brand guidelines](https://openai.com/brand/)
- [actions/checkout: license at the pinned commit](https://github.com/actions/checkout/blob/11bd71901bbe5b1630ceea73d27597364c9af683/LICENSE)
