import Foundation
import Darwin

struct Profile: Codable, Equatable {
    let id: UUID
    var name: String
}

enum AccountsError: LocalizedError {
    case message(String)
    var errorDescription: String? {
        switch self { case .message(let message): return message }
    }
}

/// Stores labels and creates empty homes. Never opens an authentication file.
final class ProfileStore {
    let root: URL
    private let fm = FileManager.default

    init(root: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/Codex Accounts")) throws {
        self.root = root
        try privateDirectory(root)
        try privateDirectory(root.appendingPathComponent("profiles"))
    }

    private func check(_ url: URL, directory: Bool) throws {
        var info = stat()
        guard lstat(url.path, &info) == 0,
              info.st_uid == getuid(),
              (info.st_mode & S_IFMT) == (directory ? S_IFDIR : S_IFREG),
              info.st_mode & 0o077 == 0,
              directory || info.st_nlink == 1 else {
            throw AccountsError.message("Unsafe permissions, owner, or link at \(url.path). No changes were made to that item.")
        }
    }

    private func privateDirectory(_ url: URL) throws {
        if mkdir(url.path, 0o700) != 0 && errno != EEXIST {
            throw AccountsError.message("Cannot create private folder: \(url.path)")
        }
        try check(url, directory: true)
    }

    private func readMetadata(_ url: URL) throws -> Data? {
        let fd = open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        if fd < 0 && errno == ENOENT { return nil }
        guard fd >= 0 else { throw AccountsError.message("Cannot open profile labels safely.") }
        defer { close(fd) }
        var info = stat()
        guard fstat(fd, &info) == 0, info.st_uid == getuid(),
              info.st_mode & S_IFMT == S_IFREG, info.st_mode & 0o077 == 0,
              info.st_nlink == 1, info.st_size <= 1_048_576 else {
            throw AccountsError.message("Unsafe profile label file.")
        }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        while true {
            let count = read(fd, &buffer, buffer.count)
            guard count >= 0 else { throw AccountsError.message("Cannot read profile labels.") }
            if count == 0 { break }
            data.append(contentsOf: buffer.prefix(count))
            guard data.count <= 1_048_576 else { throw AccountsError.message("Profile labels are too large.") }
        }
        return data
    }

    private func createFile(_ url: URL, data: Data) throws {
        let fd = open(url.path, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 0 else { throw AccountsError.message("Cannot create private file: \(url.lastPathComponent)") }
        defer { close(fd) }
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let count = write(fd, bytes.baseAddress!.advanced(by: offset), bytes.count - offset)
                guard count > 0 else { throw AccountsError.message("Cannot save private file.") }
                offset += count
            }
        }
        guard fsync(fd) == 0 else { throw AccountsError.message("Cannot flush private file.") }
    }

    func load() throws -> [Profile] {
        try check(root, directory: true)
        guard let data = try readMetadata(root.appendingPathComponent("profiles.json")) else { return [] }
        let profiles = try JSONDecoder().decode([Profile].self, from: data)
        guard Set(profiles.map(\.id)).count == profiles.count else {
            throw AccountsError.message("Duplicate profile identifiers.")
        }
        return profiles
    }

    func add(name: String) throws -> Profile {
        let label = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !label.isEmpty, label.count <= 80,
              !label.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
            throw AccountsError.message("Enter a name of 1–80 characters without control characters.")
        }
        // Lock serializes read-modify-write across launcher instances.
        let lockURL = root.appendingPathComponent("labels.lock")
        let fd = open(lockURL.path, O_RDWR | O_CREAT | O_NOFOLLOW | O_CLOEXEC, 0o600)
        guard fd >= 0 else { throw AccountsError.message("Cannot lock profile labels safely.") }
        defer { close(fd) }
        try check(lockURL, directory: false)
        guard flock(fd, LOCK_EX) == 0 else { throw AccountsError.message("Cannot lock profile labels.") }
        defer { flock(fd, LOCK_UN) }
        var profiles = try load()
        let profile = Profile(id: UUID(), name: label)
        _ = try prepare(profile)
        profiles.append(profile)
        let temporary = root.appendingPathComponent("labels-\(UUID().uuidString).tmp")
        defer { try? fm.removeItem(at: temporary) }
        try createFile(temporary, data: JSONEncoder().encode(profiles))
        guard rename(temporary.path, root.appendingPathComponent("profiles.json").path) == 0 else {
            throw AccountsError.message("Cannot replace profile labels.")
        }
        return profile
    }

    func prepare(_ profile: Profile) throws -> (home: URL, data: URL) {
        try check(root, directory: true)
        let parent = root.appendingPathComponent("profiles")
        try check(parent, directory: true)
        let folder = parent.appendingPathComponent(profile.id.uuidString.lowercased())
        try privateDirectory(folder)
        let home = folder.appendingPathComponent("home")
        let data = folder.appendingPathComponent("app-data")
        try privateDirectory(home)
        try privateDirectory(data)
        let config = home.appendingPathComponent("config.toml")
        var info = stat()
        if lstat(config.path, &info) != 0 {
            guard errno == ENOENT else { throw AccountsError.message("Cannot inspect profile configuration.") }
            try createFile(config, data: Data("cli_auth_credentials_store = \"file\"\n".utf8))
        } else {
            try check(config, directory: false)
        }
        return (home, data)
    }

    static func launchArguments(app: URL, home: URL, data: URL) -> [String] {
        ["-n", "--env", "CODEX_HOME=\(home.path)",
         "--env", "CODEX_SQLITE_HOME=\(home.path)",
         "--env", "CODEX_ELECTRON_USER_DATA_PATH=\(data.path)",
         app.path, "--args", "--user-data-dir=\(data.path)"]
    }
}
