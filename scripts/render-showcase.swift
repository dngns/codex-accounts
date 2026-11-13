// SPDX-License-Identifier: MIT
// Offscreen documentation artwork. Never launches Codex or opens real profile state.
import Foundation

let fm = FileManager.default
let output = URL(fileURLWithPath: ".build/showcase", isDirectory: true)
try fm.createDirectory(at: output, withIntermediateDirectories: true)
var source = try String(contentsOfFile: "Sources/main.swift", encoding: .utf8)
let entry = "MainActor.assumeIsolated {"
guard let cut = source.range(of: entry, options: .backwards) else { fatalError("App entry changed; review the renderer.") }
source = String(source[..<cut.lowerBound])
let storeLine = "do { store = try ProfileStore(); try refresh() } catch { show(error) }"
guard source.contains(storeLine) else { fatalError("Profile setup changed; review the renderer.") }
source = source.replacingOccurrences(of: storeLine, with: """
profiles = ["Personal", "Work", "Client"].map { Profile(id: UUID(), name: $0) }
reloadProfiles()
""")
source = source.replacingOccurrences(of: "window.makeKeyAndOrderFront(nil)", with: "// Offscreen only: no visible window.")
source = source.replacingOccurrences(of: "NSApp.activate(ignoringOtherApps: true)", with: "// Do not activate another application.")
// Mock only the final launch boundary; exercise the actual UUID-based button routing.
guard let launchStart = source.range(of: "    func openProfile(_ profile: Profile) {"),
      let launchEnd = source.range(of: "    @objc func showPrivacy()", range: launchStart.upperBound..<source.endIndex) else {
    fatalError("Launch boundary changed; review the renderer.")
}
source.replaceSubrange(launchStart.lowerBound..<launchEnd.lowerBound, with: """
    var previewOpenedProfileID: UUID?
    func openProfile(_ profile: Profile) {
        guard !busy else { return }
        previewOpenedProfileID = profile.id
    }

""")
source += try String(contentsOfFile: "scripts/showcase-scene.swift", encoding: .utf8)
try source.write(to: output.appendingPathComponent("main.swift"), atomically: true, encoding: .utf8)

func run(_ executable: String, _ arguments: [String]) throws {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: executable)
    task.arguments = arguments
    try task.run()
    task.waitUntilExit()
    guard task.terminationStatus == 0 else { fatalError("Showcase rendering failed.") }
}
try run("/usr/bin/xcrun", ["swiftc", "-module-cache-path", ".build/module-cache", "-framework", "AppKit", "-framework", "Security", "Sources/ProfileStore.swift", "Sources/OfficialApp.swift", output.appendingPathComponent("main.swift").path, "-o", output.appendingPathComponent("render").path])
try run(output.appendingPathComponent("render").path, [])
