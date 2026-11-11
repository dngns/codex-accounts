import Foundation
import Security

enum OfficialApp {
    static func validate(_ url: URL) throws {
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &code) == errSecSuccess,
              let code else { throw AccountsError.message("Cannot inspect this application's signature.") }
        var requirement: SecRequirement?
        let rule = "anchor apple generic and identifier \"com.openai.codex\" and certificate leaf[subject.OU] = \"2DC432GLL2\""
        guard SecRequirementCreateWithString(rule as CFString, [], &requirement) == errSecSuccess,
              SecStaticCodeCheckValidity(code, SecCSFlags(rawValue: kSecCSCheckAllArchitectures | kSecCSStrictValidate), requirement) == errSecSuccess else {
            throw AccountsError.message("This is not an intact Codex app signed by the expected OpenAI developer. Install the official app; this launcher will not run this copy.")
        }
    }
}
