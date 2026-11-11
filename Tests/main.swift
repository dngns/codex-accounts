import Foundation
import Darwin

var checks = 0
func expect(_ condition: Bool, _ message: String) {
    guard condition else { fatalError(message) }
    checks += 1
}
func rejects(_ message: String, _ block: () throws -> Void) {
    do { try block(); fatalError("Expected rejection: \(message)") }
    catch { checks += 1 }
}
let scratch = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
defer { try? FileManager.default.removeItem(at: scratch) }
let root = scratch.appendingPathComponent("store")
let store = try ProfileStore(root: root)
expect(try store.load().isEmpty, "Fresh store should be empty")
let a = try store.add(name: "Personal 中文 $(touch hacked); ' \" / ../")
let b = try store.add(name: "Work")
let pa = try store.prepare(a)
let pb = try store.prepare(b)
expect(pa.home != pb.home && pa.data != pb.data, "Homes must be separate")
expect(pa.home.path.contains(a.id.uuidString.lowercased()), "Directory must use UUID")
expect(!pa.home.path.contains("touch hacked"), "Label must not enter a path")
expect(try store.load().count == 2, "Metadata should persist")
let args = ProfileStore.launchArguments(app: URL(fileURLWithPath: "/Applications/Official App.app"), home: pa.home, data: pa.data)
expect(args.contains("CODEX_HOME=\(pa.home.path)"), "Home argument")
expect(args.contains("CODEX_SQLITE_HOME=\(pa.home.path)"), "Database argument")
expect(args.contains("--user-data-dir=\(pa.data.path)"), "Electron argument")
expect(!args.joined().contains(a.name), "Untrusted label must not enter command arguments")
let config = pa.home.appendingPathComponent("config.toml")
let custom = "# keep custom settings\ncli_auth_credentials_store = \"file\"\n"
try custom.write(to: config, atomically: false, encoding: .utf8)
_ = try store.prepare(a)
expect(try String(contentsOf: config, encoding: .utf8) == custom, "Existing config must be preserved")
rejects("empty name") { _ = try store.add(name: "  ") }
rejects("control characters") { _ = try store.add(name: "a\nb") }
rejects("long name") { _ = try store.add(name: String(repeating: "a", count: 81)) }
var info = stat()
lstat(root.path, &info)
expect(info.st_mode & 0o777 == 0o700, "Root must be private")
lstat(root.appendingPathComponent("profiles.json").path, &info)
expect(info.st_mode & 0o777 == 0o600, "Metadata must be private")
let linked = scratch.appendingPathComponent("linked")
try FileManager.default.createSymbolicLink(at: linked, withDestinationURL: root)
rejects("symlink store") { _ = try ProfileStore(root: linked) }
chmod(root.path, 0o755)
rejects("public store") { _ = try ProfileStore(root: root) }
chmod(root.path, 0o700)
try FileManager.default.removeItem(at: config)
let victim = scratch.appendingPathComponent("victim")
try Data("untouched".utf8).write(to: victim)
try FileManager.default.createSymbolicLink(at: config, withDestinationURL: victim)
rejects("symlink config") { _ = try store.prepare(a) }
expect(try String(contentsOf: victim, encoding: .utf8) == "untouched", "Symlink target must remain unchanged")
try FileManager.default.removeItem(at: config)
try FileManager.default.linkItem(at: victim, to: config)
rejects("hardlinked config") { _ = try store.prepare(a) }
let labels = root.appendingPathComponent("profiles.json")
try FileManager.default.removeItem(at: labels)
try FileManager.default.createSymbolicLink(at: labels, withDestinationURL: victim)
rejects("symlink labels") { _ = try store.load() }
rejects("unsigned directory as application") { try OfficialApp.validate(scratch) }
rejects("Apple binary impersonating OpenAI") { try OfficialApp.validate(URL(fileURLWithPath: "/usr/bin/true")) }
if ProcessInfo.processInfo.arguments.contains("--check-installed-app") {
    try OfficialApp.validate(URL(fileURLWithPath: "/Applications/ChatGPT.app"))
    checks += 1
}
print("Passed \(checks) security and isolation checks (temporary data only).")
