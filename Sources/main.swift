import AppKit
import Security

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {
    var window: NSWindow!
    let table = NSTableView()
    let status = NSTextField(wrappingLabelWithString: "")
    var store: ProfileStore?
    var profiles: [Profile] = []
    var busy = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        umask(0o077)
        let menu = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit Codex Accounts", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        menu.addItem(appItem)
        NSApp.mainMenu = menu

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 620, height: 480),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Codex Accounts · Preview"
        window.minSize = NSSize(width: 540, height: 440)
        let title = NSTextField(labelWithString: "Your accounts, side by side.")
        title.font = .systemFont(ofSize: 26, weight: .semibold)
        let subtitle = NSTextField(wrappingLabelWithString: "Add a profile, then sign in inside the official Codex app. Use any account that OpenAI and your organization allow.")
        subtitle.textColor = .secondaryLabelColor
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("profile"))
        column.title = "Profiles — double-click to open"
        table.addTableColumn(column)
        table.headerView = nil
        table.rowHeight = 44
        table.dataSource = self
        table.delegate = self
        table.target = self
        table.doubleAction = #selector(openProfile)
        let scroll = NSScrollView()
        scroll.documentView = table
        scroll.hasVerticalScroller = true
        scroll.borderType = .bezelBorder
        let add = NSButton(title: "＋ Add profile", target: self, action: #selector(addProfile))
        let launch = NSButton(title: "Open selected", target: self, action: #selector(openProfile))
        launch.bezelStyle = .rounded
        let privacy = NSButton(title: "Privacy & security", target: self, action: #selector(showPrivacy))
        let buttons = NSStackView(views: [add, launch, privacy])
        buttons.spacing = 12
        status.textColor = .secondaryLabelColor
        status.font = .systemFont(ofSize: 12)
        let stack = NSStackView(views: [title, subtitle, scroll, buttons, status])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        window.contentView!.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 28),
            stack.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor, constant: -24),
            scroll.widthAnchor.constraint(equalTo: stack.widthAnchor),
            scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        do { store = try ProfileStore(); try refresh() } catch { show(error) }
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func numberOfRows(in tableView: NSTableView) -> Int { profiles.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let label = NSTextField(labelWithString: "  ◉  \(profiles[row].name)")
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }

    func refresh() throws {
        profiles = try store?.load() ?? []
        table.reloadData()
        status.stringValue = profiles.isEmpty ? "Start with Add profile. Existing Codex accounts are left untouched." : "Labels are yours to choose. Verify the signed-in account in each Codex window."
    }

    func show(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }

    @objc func addProfile() {
        guard !busy, let store else { return }
        let alert = NSAlert()
        alert.messageText = "Add a profile"
        alert.informativeText = "Choose a label such as Personal, Work, or Client. No email or password is needed here. A new, empty profile will be created."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 26))
        field.placeholderString = "Profile name"
        alert.accessoryView = field
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = field
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        do {
            let profile = try store.add(name: field.stringValue)
            try refresh()
            if let row = profiles.firstIndex(of: profile) { table.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false) }
        } catch { show(error) }
    }

    func findApp() throws -> URL? {
        for path in ["/Applications/ChatGPT.app", "/Applications/Codex.app",
                     NSHomeDirectory() + "/Applications/ChatGPT.app", NSHomeDirectory() + "/Applications/Codex.app"] {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                try OfficialApp.validate(url)
                return url
            }
        }
        let panel = NSOpenPanel()
        panel.title = "Choose the official Codex application"
        panel.message = "Install the official app first if needed. Its OpenAI signature will be verified."
        panel.allowedContentTypes = [.applicationBundle]
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        try OfficialApp.validate(url)
        return url
    }

    @objc func openProfile() {
        guard !busy, let store, profiles.indices.contains(table.selectedRow) else { return }
        do {
            guard let app = try findApp() else { return }
            let profile = profiles[table.selectedRow]
            let paths = try store.prepare(profile)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = ProfileStore.launchArguments(app: app, home: paths.home, data: paths.data)
            // No shell, inherited API keys, endpoint overrides, or injected libraries.
            process.environment = ["HOME": NSHomeDirectory(), "USER": NSUserName(),
                                   "LOGNAME": NSUserName(), "PATH": "/usr/bin:/bin:/usr/sbin:/sbin",
                                   "TMPDIR": NSTemporaryDirectory()]
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice
            busy = true
            status.stringValue = "Opening \(profile.name)…"
            process.terminationHandler = { task in
                let succeeded = task.terminationStatus == 0
                DispatchQueue.main.async {
                    self.busy = false
                    self.status.stringValue = succeeded
                        ? "Opened \(profile.name). Sign in and verify your email/workspace in Codex."
                        : "macOS could not open Codex. Check the official installation and try again."
                }
            }
            try process.run()
        } catch { busy = false; show(error) }
    }

    @objc func showPrivacy() {
        let alert = NSAlert()
        alert.messageText = "Your login stays with the official app"
        alert.informativeText = "This launcher has no networking, telemetry, login form, or updater. It stores only profile labels and creates separate local folders. It never reads or copies tokens.\n\nThe official app stores login credentials locally. Other software running as your macOS user may access them. Profiles are not a security sandbox.\n\nThis experimental launcher is independent of OpenAI. macOS and organization policies still apply."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.regular)
    app.run()
}
