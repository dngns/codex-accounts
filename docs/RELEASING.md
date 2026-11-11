# Release presentation checklist

Keep a release readable for someone who has never opened the repository.

1. Use a short title: `Codex Accounts <version> Preview — <specific change>`. Preserve prerelease status until the acceptance and signing work is complete.
2. Put one relevant, version-accurate project image near the top. Use an absolute image URL pinned to a full commit SHA; relative README image links will not resolve the same way in release bodies.
3. Provide a small package table: platform, architecture, direct download, and checksum. Keep existing filenames/links intact when changing presentation.
4. Put the signing/Gatekeeper status next to the download. Do not claim a downloaded double-click experience while the package remains unnotarized.
5. Give three installation steps, then version-specific changes. Separate measured checks from pending acceptance work.
6. Link the source tree at the version's tag, security model, licensing, validation, and comparison where appropriate.
7. Use readable asset labels without renaming an already published binary. Never replace a published ZIP or checksum merely to change release copy.
8. Verify image URLs, download targets, labels, prerelease status, and archive checksum after publishing.

For a documentation/presentation refresh, edit existing release titles/bodies. Do not invent an application version or new binary change. Preserve the tagged source and existing release assets. An old version should link to its successor without claiming the newer version's features.

The repository currently uses a universal preview ZIP rather than separate architecture downloads. The source archives GitHub adds automatically are not prebuilt applications; make this distinction clear to non-developers.
