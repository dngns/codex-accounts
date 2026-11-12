# Approved double-C icon

Approved by the maintainer in chat on **2026-11-12**. This is the raster image chosen after the earlier geometric drafts; those drafts are not production artwork.

| Item | Value |
| --- | --- |
| Creation tool | Built-in OpenAI `image_gen.imagegen` (not CLI/API fallback) |
| Input | Text-only project brief; no reference images |
| Original | [`assets/AppIcon-source.png`](../assets/AppIcon-source.png), 1254×1254 RGBA |
| Original SHA-256 | `b3c85f5b668ee0bc81cb3d2ee2c270c62eeea05db4c3e4abed485bdcdbc124b1` |
| App/README image | [`assets/AppIcon.png`](../assets/AppIcon.png), 1024×1024 RGBA |
| Packaging | [`scripts/generate-icon.swift`](../scripts/generate-icon.swift) |

The original file is preserved unchanged. Packaging resizes and centers the approved raster image with a consistent transparent margin, and clips stray outer pixels to the rounded macOS tile. It preserves the monogram geometry, colors and material treatment. The same source produces all ten standard iconset PNG representations and an ICNS resource. The build verifies the source hash and does not call an image-generation service.

This asset is not an editable SVG, layered Icon Composer asset or hand-drawn vector. Older SVG artwork remains in historical Git tags. AI generation does not establish exclusive copyright, uniqueness or trademark clearance. The project's MIT grant applies only where rights exist and can be granted; see [LICENSING.md](../LICENSING.md).

## Exact generation request

The built-in tool was called with `transparent_background: true` and this prompt:

```text
Use case: logo-brand. Create ONE beautifully art-directed, minimal native macOS application icon concept for an independent app called Codex Accounts. The app opens multiple independent profiles of the same official desktop application. This is a fresh branding concept, NOT a UI diagram. Central idea: one compact ORIGINAL monogram composed of TWO clearly discernible offset capital C forms, repeating the same identity to suggest multiple profiles. The two C forms should form a considered cohesive mark, with sophisticated optical spacing and a narrow negative-space separation, not a chain, not infinity, not interlocking rings. Both Cs open toward the right. No third-party logo references. Background: a pearl-white porcelain macOS rounded-square tile with the familiar generous macOS corner curvature and modest inset padding, subtle cool-gray material depth, near-front orthographic view. Foreground: charcoal graphite front C and a restrained medium-gray rear C offset a little upward and left, broad soft-edged geometric strokes, no thin outlines. Large bold restrained silhouette, generous breathing space. Premium native macOS app-icon craft: very subtle edge highlights and contact depth, believable tactile finish, clean even light, crisp silhouette, no heavy fake gloss. Monochrome white/graphite only. Icon occupies about 85% of square canvas, centered. Background OUTSIDE the rounded-square tile is genuinely transparent. Only the single icon, no presentation board, no labels, no explanation, no wordmark, no captions. No people, heads, terminal prompt, windows, tabs, binder/calendar shapes, files, folders, shields, keys, locks, neon, purple/mint gradients, floating particles, ribbons, Apple logo, OpenAI logo, ChatGPT logo, or copied brand marks. The exact same two C glyph shapes repeat to express multiplicity. Aim for a designed, memorable brand mark with exceptional proportion rather than generic clip art.
```

This records the request, not a guarantee that every visual constraint was achieved or that no similar mark exists. The source PNG is the reproducible build input; running the prompt again may create a different result.
