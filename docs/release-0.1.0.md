## First public preview

A small native macOS launcher for keeping separate account profiles in the official Codex app. Independent of OpenAI.

> [!NOTE]
> **A newer preview is available:** [0.1.1 adds an original app icon and clearer licensing](https://github.com/dngns/codex-accounts/releases/tag/v0.1.1-preview.1). New users should start there.

### Included in this version

- Add a profile label, then open its separate Codex home and desktop data folder.
- Sign in through the official app. No launcher password form or token import.
- Verify the selected official app's signature before launch.

### Downloads

| Package | Platform | Link |
| --- | --- | --- |
| Universal app ZIP | macOS 13+ · Apple Silicon and Intel build targets | [Download 0.1.0](https://github.com/dngns/codex-accounts/releases/download/v0.1.0-preview.1/Codex-Accounts-preview-universal.zip) |
| SHA-256 | Archive integrity | [Checksums](https://github.com/dngns/codex-accounts/releases/download/v0.1.0-preview.1/SHA256SUMS) |

> [!IMPORTANT]
> This historical preview is ad-hoc signed, not Developer ID signed or notarized. macOS may block it. Do not disable Gatekeeper or remove quarantine. Full multi-account login, Intel runtime, and clean-machine download acceptance remain pending.

Install the official Codex app separately. Unzip the launcher, add a profile, then sign in inside the official app and verify the email/workspace. Sign in to new profiles one at a time.

Separate profiles are not an OS security boundary. Keep locally stored credentials private; OpenAI and organization account policies still apply.

[Source at 0.1.0](https://github.com/dngns/codex-accounts/tree/v0.1.0-preview.1) · [Current security model](https://github.com/dngns/codex-accounts/blob/main/SECURITY.md) · [Current licensing](https://github.com/dngns/codex-accounts/blob/main/LICENSING.md)
