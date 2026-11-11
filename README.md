# Codex Accounts

A tiny, open-source macOS launcher for opening multiple accounts in the official Codex desktop app. **Experimental preview, independent of OpenAI.**

No account manager service. No passwords entered here. No token import. No runtime dependencies. No built-in networking, analytics, or updater.

## Use

1. Install the official Codex desktop app from OpenAI first.
2. Download `Codex-Accounts-preview-universal.zip` from this repository's Releases, unzip, and open **Codex Accounts.app**. You can move it into Applications.
3. Choose **Add profile**, enter a label, select it, and choose **Open selected**.
4. Sign in using the official app's normal sign-in flow. Repeat for another account.

Profiles accept any label and impose no email/domain filter. Actual account eligibility, SSO, workspace restrictions, and organization policies are controlled by OpenAI and your organization. When the browser offers a previously used account, choose the intended account there and verify the email/workspace inside Codex. Labels do not verify identity.

**Preview distribution:** this release is ad-hoc signed, not Developer ID signed or notarized. macOS may block a download from opening. A frictionless downloaded double-click release requires Developer ID signing and Apple notarization, which are not configured yet. Do not disable Gatekeeper or remove quarantine to use this project. If macOS blocks it, wait for a notarized release or build the reviewed source yourself.

The launcher itself opens by double-click; the official app must already be installed, each new profile still requires sign-in, and macOS may display normal consent dialogs. No administrator permission is needed by the launcher.

## Where is my data?

```text
~/Library/Application Support/Codex Accounts/
  profiles.json                     # UUIDs and labels only
  profiles/<random-uuid>/home/       # official Codex configuration and state
  profiles/<random-uuid>/app-data/   # official desktop application state
```

New folders have mode `0700`; launcher-created files have mode `0600`. The official app owns the credentials it creates. File credential storage is explicitly selected for fresh profiles so each has its own home. Credentials are sensitive plaintext tokens; do not share, commit, or sync these folders. The launcher never opens credential files.

Your current `~/.codex`, existing custom launchers, and other profile directories are not imported or modified. Removing this launcher does not sign out or erase profile data. Sign out inside each official app window before retiring a profile. This preview deliberately has no destructive delete or credential export feature.

## Security and trust

See [SECURITY.md](SECURITY.md) for the threat model and verification steps. Anyone can inspect the complete runtime implementation in [Sources](Sources). It uses Apple system frameworks only and launches `/usr/bin/open` with an argument array, without a shell. It validates the selected official app's code signature, bundle identifier, and OpenAI team before launching it. There is no website or backend operated by this project.

Open source and signatures help inspection and integrity; neither is a guarantee against account theft. A malicious replacement binary, compromised Mac, another app running as your macOS user, or a compromised official app can still expose local credentials. These profiles are data separation within one macOS user, **not an OS security boundary**. Never attach profile data or authentication files to issues.

## Compatibility

- Universal binary: Apple Silicon and Intel, macOS 13+ build target. Cross-compilation is checked; an Intel runtime and clean downloaded-Mac test are still needed.
- Official app identity expected: `com.openai.codex`, signing team `2DC432GLL2`. A legitimate future identity change requires a reviewed launcher update. There is no signature bypass.
- Launch mechanism: explicit `CODEX_HOME`, `CODEX_SQLITE_HOME`, `CODEX_ELECTRON_USER_DATA_PATH`, and `--user-data-dir` with `open -n`.
- Based on the installed official desktop build `26.1103.60933`. The desktop-specific mechanism is internal implementation evidence, **not a documented promise of multi-account support**. Future updates may change behavior. Re-login may be required.
- Only the profile launcher has distinct branding; official account windows can share the same name and Dock icon.
- Multiple accounts, OAuth callbacks, and repeated opens require an interactive acceptance test. Check the actual signed-in account before using a profile for sensitive work.

## Build and test

Requires macOS and Xcode Command Line Tools. End users of a packaged build do not need Swift, Python, Node, Homebrew, or Terminal.

```sh
bash scripts/test.sh
bash scripts/build.sh
```

The universal preview ZIP and SHA-256 checksum are written to `dist/`. Tests use temporary directories and do not touch real account state. GitHub Actions builds the same sources; there are no package downloads or third-party build dependencies beyond the pinned checkout action and Apple's installed tools.

### Notarized release (maintainer)

Obtain a Developer ID Application certificate and configure a `notarytool` keychain profile on a trusted build Mac. Never commit certificates, passwords, keys, or credential data. After building:

```sh
DEVELOPER_ID='Developer ID Application: Your Name (TEAMID)' \
NOTARY_PROFILE='your-keychain-profile' bash scripts/notarize.sh
```

The script requires successful notarization, stapling, and Gatekeeper assessment before packaging the production ZIP. Test that ZIP downloaded through a browser on a clean Mac before calling it a double-click release. A checksum shipped in the same release detects accidental changes; it does not prove publisher identity if the release account is compromised.

## References

- [OpenAI: authentication and credential storage](https://learn.chatgpt.com/docs/auth)
- [Apple: Developer ID](https://developer.apple.com/developer-id/)
- [Apple: notarizing macOS software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)

MIT licensed. Codex and OpenAI names identify the app being launched; this project is not affiliated with or endorsed by OpenAI.

## Tiếng Việt

Đây là launcher thử nghiệm để mở nhiều tài khoản Codex cạnh nhau trên macOS. Tạo profile, đặt tên, rồi đăng nhập trong app chính thức. Không phân biệt email/domain; quyền truy cập vẫn theo OpenAI và tổ chức của bạn. Launcher không có form mật khẩu, không đọc/copy token và không gửi dữ liệu qua mạng. Các thư mục profile vẫn chứa dữ liệu nhạy cảm do app chính thức lưu; không chia sẻ các thư mục đó. Chưa có Developer ID/notarization nên chưa thể hứa bản tải về sẽ mở ngay bằng click đúp trên máy khác. Không tắt Gatekeeper để chạy bản thử.
