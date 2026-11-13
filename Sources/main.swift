// SPDX-License-Identifier: MIT
import AppKit
import Security

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {
    var window: NSWindow!
    let table = NSTableView()
    let status = NSTextField(wrappingLabelWithString: "")
    var store: ProfileStore?
    var profiles: [Profile] = []
    var busy = false {
        didSet { updateControls() }
    }
    let addButton = NSButton()
    let countLabel = NSTextField(labelWithString: "")
    let emptyState = NSStackView()

    func applicationDidFinishLaunching(_ notification: Notification) {
        umask(0o077)
        let menu = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Codex Accounts", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        let licenseItem = appMenu.addItem(withTitle: "License & notices…", action: #selector(showLicensing), keyEquivalent: "")
        licenseItem.target = self
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit Codex Accounts", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        menu.addItem(appItem)
        NSApp.mainMenu = menu

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 520),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Codex Accounts"
        window.minSize = NSSize(width: 580, height: 460)
        let root = window.contentView!
        let title = NSTextField(labelWithString: "Your profiles")
        title.font = .systemFont(ofSize: 27, weight: .semibold)
        let subtitle = NSTextField(wrappingLabelWithString: "A separate space for each account.")
        subtitle.font = .systemFont(ofSize: 13)
        subtitle.textColor = .secondaryLabelColor
        let titles = NSStackView(views: [title, subtitle])
        titles.orientation = .vertical
        titles.alignment = .leading
        titles.spacing = 5
        addButton.title = "Add profile…"
        addButton.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
        addButton.imagePosition = .imageLeading
        addButton.bezelStyle = .rounded
        addButton.controlSize = .large
        addButton.target = self
        addButton.action = #selector(addProfile)
        addButton.setAccessibilityLabel("Add a new profile")
        let header = NSStackView(views: [titles, NSView(), addButton])
        header.alignment = .centerY
        header.distribution = .fill

        countLabel.font = .systemFont(ofSize: 11, weight: .medium)
        countLabel.textColor = .secondaryLabelColor
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("profile"))
        table.addTableColumn(column)
        table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        table.headerView = nil
        table.rowHeight = 76
        table.intercellSpacing = NSSize(width: 0, height: 6)
        table.style = .plain
        table.selectionHighlightStyle = .none
        table.allowsEmptySelection = true
        table.backgroundColor = .clear
        table.dataSource = self
        table.delegate = self
        table.target = self
        table.doubleAction = #selector(openClickedRow)
        let scroll = NSScrollView()
        scroll.documentView = table
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.borderType = .noBorder

        let emptyTitle = NSTextField(labelWithString: "Create your first profile")
        emptyTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        let emptyText = NSTextField(wrappingLabelWithString: "Use Add profile to make a space for Personal, Work, or a client.")
        emptyText.font = .systemFont(ofSize: 13)
        emptyText.textColor = .secondaryLabelColor
        emptyText.alignment = .center
        emptyState.setViews([emptyTitle, emptyText], in: .center)
        emptyState.orientation = .vertical
        emptyState.alignment = .centerX
        emptyState.spacing = 10
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(emptyState)
        NSLayoutConstraint.activate([
            emptyState.centerXAnchor.constraint(equalTo: scroll.centerXAnchor),
            emptyState.centerYAnchor.constraint(equalTo: scroll.centerYAnchor),
            emptyState.widthAnchor.constraint(lessThanOrEqualTo: scroll.widthAnchor, constant: -50)
        ])

        status.textColor = .secondaryLabelColor
        status.font = .systemFont(ofSize: 12)
        status.stringValue = "Sign in and verify your account in the Codex window."
        let privacy = NSButton(title: "Privacy & security", target: self, action: #selector(showPrivacy))
        privacy.bezelStyle = .inline
        privacy.isBordered = false
        privacy.font = .systemFont(ofSize: 12)
        let independent = NSTextField(labelWithString: "Independent project · not affiliated with OpenAI")
        independent.textColor = .tertiaryLabelColor
        independent.font = .systemFont(ofSize: 11)
        let footer = NSStackView(views: [independent, NSView(), privacy])
        footer.alignment = .centerY
        let separator = NSBox()
        separator.boxType = .separator
        let stack = NSStackView(views: [header, countLabel, scroll, status, separator, footer])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: root.topAnchor, constant: 26),
            stack.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -20),
            header.widthAnchor.constraint(equalTo: stack.widthAnchor),
            scroll.widthAnchor.constraint(equalTo: stack.widthAnchor),
            scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 170),
            separator.widthAnchor.constraint(equalTo: stack.widthAnchor),
            footer.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
        do { store = try ProfileStore(); try refresh() } catch { show(error) }
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func numberOfRows(in tableView: NSTableView) -> Int { profiles.count }
    func selectionShouldChange(in tableView: NSTableView) -> Bool { false }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let profile = profiles[row]
        let cell = NSTableCellView()
        let card = NSBox()
        card.boxType = .custom
        card.borderWidth = 0.5
        card.borderColor = .separatorColor.withAlphaComponent(0.4)
        card.fillColor = .controlBackgroundColor
        card.cornerRadius = 12
        card.contentViewMargins = .zero
        card.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(card)
        let content = card.contentView!
        let badge = NSBox()
        badge.boxType = .custom
        badge.borderWidth = 0
        badge.fillColor = .quaternaryLabelColor
        badge.cornerRadius = 9
        badge.contentViewMargins = .zero
        let initial = NSTextField(labelWithString: String(profile.name.prefix(1)).uppercased())
        initial.font = .systemFont(ofSize: 16, weight: .semibold)
        initial.alignment = .center
        initial.translatesAutoresizingMaskIntoConstraints = false
        badge.contentView!.addSubview(initial)
        NSLayoutConstraint.activate([
            initial.centerXAnchor.constraint(equalTo: badge.contentView!.centerXAnchor),
            initial.centerYAnchor.constraint(equalTo: badge.contentView!.centerYAnchor)
        ])
        let name = NSTextField(labelWithString: profile.name)
        name.font = .systemFont(ofSize: 15, weight: .medium)
        name.lineBreakMode = .byTruncatingTail
        name.toolTip = profile.name
        name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        name.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .horizontal)
        cell.textField = name
        let open = NSButton(title: "Open", target: self, action: #selector(openProfileButton(_:)))
        open.bezelStyle = .rounded
        open.controlSize = .large
        open.identifier = NSUserInterfaceItemIdentifier(profile.id.uuidString)
        open.setAccessibilityLabel("Open \(profile.name) in Codex")
        open.isEnabled = !busy
        let line = NSStackView(views: [badge, name, open])
        line.alignment = .centerY
        line.distribution = .fill
        line.spacing = 14
        line.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(line)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 1),
            card.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -1),
            card.topAnchor.constraint(equalTo: cell.topAnchor, constant: 2),
            card.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -2),
            line.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            line.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            badge.widthAnchor.constraint(equalToConstant: 36),
            badge.heightAnchor.constraint(equalToConstant: 36),
            open.widthAnchor.constraint(greaterThanOrEqualToConstant: 76)
        ])
        return cell
    }

    func updateControls() {
        addButton.isEnabled = !busy
        table.reloadData()
    }

    func refresh() throws {
        profiles = try store?.load() ?? []
        reloadProfiles()
    }

    func reloadProfiles() {
        countLabel.stringValue = profiles.isEmpty ? "PROFILES" : "\(profiles.count) PROFILE\(profiles.count == 1 ? "" : "S")"
        emptyState.isHidden = !profiles.isEmpty
        updateControls()
    }

    func show(_ error: Error) {
        NSAlert(error: error).beginSheetModal(for: window)
    }

    @objc func addProfile() {
        guard !busy, let store else { return }
        let alert = NSAlert()
        alert.messageText = "Add a profile"
        alert.informativeText = "Choose a name such as Personal, Work, or Client. Sign in later in the official Codex app."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 26))
        field.placeholderString = "Profile name"
        alert.accessoryView = field
        alert.addButton(withTitle: "Add profile")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = field
        alert.beginSheetModal(for: window) { response in
            guard response == .alertFirstButtonReturn else { return }
            do {
                let profile = try store.add(name: field.stringValue)
                try self.refresh()
                if let row = self.profiles.firstIndex(of: profile) { self.table.scrollRowToVisible(row) }
            } catch { self.show(error) }
        }
    }

    @objc func openProfileButton(_ sender: NSButton) {
        guard let value = sender.identifier?.rawValue,
              let id = UUID(uuidString: value),
              let profile = profiles.first(where: { $0.id == id }) else { return }
        openProfile(profile)
    }

    @objc func openClickedRow() {
        guard profiles.indices.contains(table.clickedRow) else { return }
        openProfile(profiles[table.clickedRow])
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

    func openProfile(_ profile: Profile) {
        guard !busy, let store else { return }
        do {
            guard let app = try findApp() else { return }
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

    @objc func showLicensing() {
        let alert = NSAlert()
        alert.messageText = "License & artwork"
        alert.informativeText = "Project code, documentation, and icon artwork are offered under the MIT license where copyright applies. Keep the copyright and license notices when redistributing. See the bundled licensing document for the AI-assisted artwork's provenance.\n\nOpenAI names identify the compatible app; they are not licensed by this project. This launcher is independent and is not endorsed by OpenAI. No OpenAI logo, stock image, bundled font, or third-party icon pack is included."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Read bundled notices")
        if alert.runModal() == .alertSecondButtonReturn,
           let url = Bundle.main.url(forResource: "LICENSING", withExtension: "md") {
            NSWorkspace.shared.open(url)
        }
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.regular)
    app.run()
}
