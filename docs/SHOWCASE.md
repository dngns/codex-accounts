# Showcase artwork

[Back to README](../README.md)

`assets/showcase.png` is an **offscreen native UI render**, not a screenshot of real signed-in accounts. The Personal, Work, and Client names are fixture labels. No account is connected and no profile store is opened during rendering.

`scripts/render-showcase.swift` derives a temporary renderer from `Sources/main.swift`, removes the app event-loop entry, replaces profile-store initialization with fixture labels, and removes window presentation/activation. It then appends `scripts/showcase-scene.swift` and compiles against the same UI code. Rendering fails if the expected source entry/setup no longer matches, so a changed interface requires review.

The composition adds project-written copy and simple geometry around that native view. `assets/quickstart.png` is a companion three-step explainer. Both are original, AI-assisted documentation artwork under the project's MIT terms where applicable. macOS system font APIs render the text; no font file, stock photograph, third-party logo or icon library is shipped. Badge and download-button SVGs are also project-authored geometry/text. GitHub's live build badge is referenced from GitHub, not vendored.

## Reproduce

From the repository root on a Mac with Xcode Command Line Tools:

```sh
xcrun swift -module-cache-path .build/module-cache scripts/render-showcase.swift
```

Outputs:

- `assets/showcase.png` — 1800 × 1040.
- `assets/quickstart.png` — 1800 × 400.
- `.build/showcase/` — temporary compiled renderer and derived source, ignored by Git.

Review both images after regeneration. The renderer does not launch the official Codex app, sign in, open browser windows, or read real profile/authentication files. Developer tooling may need ordinary macOS drawing-service access outside a restricted execution sandbox.

Release bodies use absolute image URLs pinned to the documentation commit, so later artwork changes cannot silently alter an older release's showcase. README uses relative asset paths. These images demonstrate the interface and workflow, not successful simultaneous authentication or a security guarantee.

## Presentation references

The information hierarchy was informed by [taste-skill](https://github.com/Leonxlnx/taste-skill), [LocalSend](https://github.com/localsend/localsend), and [Zed](https://github.com/zed-industries/zed): a recognizable header, visual examples near the top, a clear installation/download path, and separate contributor detail. No image, logo, source file, or copy from those projects is included here.
