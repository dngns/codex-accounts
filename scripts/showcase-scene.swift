// SPDX-License-Identifier: MIT
// Appended to a source-derived, offscreen AppDelegate by render-showcase.swift.

func ink(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: 1)
}
func box(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ radius: CGFloat, _ hex: UInt32) {
    ink(hex).setFill()
    NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: radius, yRadius: radius).fill()
}
func text(_ value: String, _ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ size: CGFloat,
          _ hex: UInt32 = 0xF4F5FA, _ weight: NSFont.Weight = .regular) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = 5
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: ink(hex), .paragraphStyle: paragraph
    ]
    (value as NSString).draw(in: NSRect(x: x, y: y, width: width, height: 500), withAttributes: attributes)
}
func canvas(_ width: Int, _ height: Int, _ draw: () -> Void) -> Data {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
                                  bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                  isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    let baseContext = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.current = NSGraphicsContext(cgContext: baseContext.cgContext, flipped: true)
    let transform = NSAffineTransform()
    transform.translateX(by: 0, yBy: CGFloat(height))
    transform.scaleX(by: 1, yBy: -1)
    transform.concat()
    draw()
    NSGraphicsContext.restoreGraphicsState()
    return bitmap.representation(using: .png, properties: [:])!
}

func opaquePNG(_ original: NSBitmapImageRep, appearance: NSAppearance) -> Data {
    let result = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: original.pixelsWide,
                                  pixelsHigh: original.pixelsHigh, bitsPerSample: 8,
                                  samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let image = NSImage(size: NSSize(width: original.pixelsWide, height: original.pixelsHigh))
    image.addRepresentation(original)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: result)
    appearance.performAsCurrentDrawingAppearance {
        let frame = NSRect(x: 0, y: 0, width: original.pixelsWide, height: original.pixelsHigh)
        NSColor.windowBackgroundColor.setFill()
        NSBezierPath(rect: frame).fill()
        image.draw(in: frame, from: .zero, operation: .sourceOver, fraction: 1)
    }
    NSGraphicsContext.restoreGraphicsState()
    return result.representation(using: .png, properties: [:])!
}

MainActor.assumeIsolated {
    let application = NSApplication.shared
    application.appearance = NSAppearance(named: .aqua)
    let delegate = AppDelegate()
    delegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))
    delegate.window.appearance = NSAppearance(named: .aqua)
    let view = delegate.window.contentView!
    view.layoutSubtreeIfNeeded()
    func buttons(_ view: NSView) -> [NSButton] {
        (view as? NSButton).map { [$0] } ?? view.subviews.flatMap { buttons($0) }
    }
    func rowButton(_ row: Int) -> NSButton {
        let cell = delegate.table.view(atColumn: 0, row: row, makeIfNecessary: true)!
        return buttons(cell).first { $0.identifier != nil }!
    }
    let savedProfiles = delegate.profiles
    var checks = 0
    for row in savedProfiles.indices {
        delegate.previewOpenedProfileID = nil
        rowButton(row).performClick(nil)
        precondition(delegate.previewOpenedProfileID == savedProfiles[row].id, "Open must route to that row's UUID.")
        checks += 1
    }
    let oldButton = rowButton(0)
    delegate.profiles.reverse()
    delegate.reloadProfiles()
    oldButton.performClick(nil)
    precondition(delegate.previewOpenedProfileID == savedProfiles[0].id, "Reordering must not change a button's target.")
    checks += 1
    delegate.profiles.removeAll { $0.id == savedProfiles[0].id }
    delegate.reloadProfiles()
    delegate.previewOpenedProfileID = nil
    oldButton.performClick(nil)
    precondition(delegate.previewOpenedProfileID == nil, "A stale button must not open a different profile.")
    checks += 1
    delegate.busy = true
    precondition(!delegate.addButton.isEnabled && !rowButton(0).isEnabled, "Disable launch/add while busy.")
    checks += 1
    delegate.busy = false
    delegate.profiles = []
    delegate.reloadProfiles()
    precondition(!delegate.emptyState.isHidden && delegate.table.numberOfRows == 0, "Empty state must be visible.")
    checks += 1
    delegate.profiles = [Profile(id: UUID(), name: String(repeating: "Long profile ", count: 6))]
    delegate.reloadProfiles()
    delegate.window.setContentSize(NSSize(width: 580, height: 440))
    view.layoutSubtreeIfNeeded()
    let longButton = rowButton(0)
    let buttonRect = longButton.convert(longButton.bounds, to: view)
    precondition(buttonRect.maxX <= view.bounds.maxX - 20 && buttonRect.width >= 70, "Long names must leave the Open button visible.")
    checks += 1
    delegate.profiles = savedProfiles
    delegate.window.setContentSize(NSSize(width: 640, height: 520))
    delegate.reloadProfiles()
    view.layoutSubtreeIfNeeded()
    let bounds = view.bounds
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(bounds.width * 2),
                                  pixelsHigh: Int(bounds.height * 2), bitsPerSample: 8,
                                  samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                  colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    bitmap.size = bounds.size
    view.cacheDisplay(in: bounds, to: bitmap)
    try! opaquePNG(bitmap, appearance: NSAppearance(named: .aqua)!).write(to: URL(fileURLWithPath: "assets/profile-ui-light.png"))
    let nativeUI = NSImage(size: bounds.size)
    nativeUI.addRepresentation(bitmap)
    let hero = canvas(1800, 1040) {
        box(0, 0, 1800, 1040, 0, 0x101725)
        box(88, 76, 286, 40, 20, 0x233C38)
        text("INDEPENDENT macOS APP", 106, 84, 270, 17, 0x8EE4CA, .semibold)
        text("Codex Accounts", 88, 146, 650, 38, 0xF4F5FA, .semibold)
        text("A home for\nevery account.", 88, 288, 680, 78, 0xF4F5FA, .bold)
        text("Personal. Work. Client.\nSeparate profiles for the official Codex app.", 94, 515, 600, 28, 0xAAB5C8)
        box(94, 678, 410, 64, 16, 0x70E2C2)
        text("Add a profile. Open. Sign in.", 118, 695, 390, 23, 0x112B28, .semibold)
        text("No password form. No token import.\nNo networking in the launcher.", 94, 790, 600, 25, 0xC9D1DF)

        box(760, 216, 950, 776, 28, 0x080E19)
        box(748, 202, 950, 776, 24, 0xEAEAEA)
        box(748, 202, 950, 52, 24, 0xEAEAEA)
        for (i, color) in [UInt32(0xFF6058), UInt32(0xFFBD2E), UInt32(0x28CA42)].enumerated() {
            box(774 + CGFloat(i) * 27, 220, 16, 16, 8, color)
        }
        text("Codex Accounts", 1000, 216, 500, 19, 0x4B4B50, .medium)
        nativeUI.draw(in: NSRect(x: 748, y: 254, width: 950, height: 724),
                      from: .zero, operation: .sourceOver, fraction: 1,
                      respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
        text("Native UI render · example labels · no accounts connected", 792, 148, 920, 20, 0xAAB5C8)
        text("EXPERIMENTAL PREVIEW", 94, 974, 620, 18, 0xA49AFF, .semibold)
    }
    try! hero.write(to: URL(fileURLWithPath: "assets/showcase.png"))

    let workflow = canvas(1800, 400) {
        box(0, 0, 1800, 400, 24, 0x151F30)
        let steps = [
            ("01", "Name a profile", "Personal, Work, or Client.\nJust a label — no email required."),
            ("02", "Open the profile", "Click Open beside the profile\nyou want to use."),
            ("03", "Sign in with OpenAI", "Use the official app's login.\nVerify your email and workspace.")
        ]
        for (index, step) in steps.enumerated() {
            let x = CGFloat(index) * 580 + 65
            text(step.0, x, 48, 500, 23, 0x70E2C2, .semibold)
            text(step.1, x, 108, 500, 35, 0xF4F5FA, .semibold)
            text(step.2, x, 178, 500, 25, 0xB5C0D2)
        }
        box(65, 316, 1670, 1, 0, 0x334157)
        text("Repeat for another account. Sign in to new profiles one at a time.", 65, 342, 1600, 22, 0x9DAFC5)
    }
    try! workflow.write(to: URL(fileURLWithPath: "assets/quickstart.png"))
    application.appearance = NSAppearance(named: .darkAqua)
    delegate.window.appearance = NSAppearance(named: .darkAqua)
    delegate.reloadProfiles()
    view.layoutSubtreeIfNeeded()
    view.cacheDisplay(in: bounds, to: bitmap)
    try! opaquePNG(bitmap, appearance: NSAppearance(named: .darkAqua)!).write(to: URL(fileURLWithPath: "assets/profile-ui-dark.png"))
    print("Passed \(checks) UI routing, busy-state, empty-state and long-name checks (mock launch; no credentials).")
    print("Rendered showcase.png and quickstart.png offscreen with demo labels only.")
}
