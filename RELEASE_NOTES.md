## 0.1.0 — experimental preview

Small native macOS launcher for separate official Codex account profiles.

- Add a label and open the selected profile; sign in only through the official app.
- Separate local homes and desktop data folders; existing account data is untouched.
- OpenAI application signature validation, no shell execution, private file permissions, no networking or telemetry in the launcher.
- Universal Apple Silicon / Intel package, no runtime language dependencies.

**This preview is ad-hoc signed, not Developer ID signed or notarized. macOS may block the downloaded app. Do not disable Gatekeeper or remove quarantine. A production double-click download requires a future notarized release.**

Requires the official Codex desktop app. Profile labels have no email/domain restrictions, but service eligibility and managed organization policies still apply. Desktop profile launch flags are internal and may change. Full multi-account login, Intel runtime, and clean-machine download acceptance remain pending; see VALIDATION.md.

Download `Codex-Accounts-preview-universal.zip` and consult README.md and SECURITY.md before use. `SHA256SUMS` checks archive integrity, not publisher identity. No credentials or private account state are included.
