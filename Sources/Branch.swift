import Foundation

public protocol Branch {  }

public struct MasterBranch: Branch { }

public struct InvalidBranch: Branch { }

public struct NamedBranch: Branch {
    public let path: [String]
    public let name: String
}

struct _Branch {
    private static let prefix = "ref: refs/heads/"
    private static let master = "master"
    
    static func current(_ at: URL) -> Branch {
        let content = String(decoding: (try? Data(contentsOf: at.HEAD)) ?? .init(), as: UTF8.self)
        guard content.hasPrefix(prefix) else {
            return InvalidBranch()
        }
        let name = content.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
        guard name == master else {
            return {
                NamedBranch(path: $0.dropLast(), name: $0.last!)
            } (name.components(separatedBy: "/"))
        }
        return MasterBranch()
    }
    
    static func checkoutMaster(_ url: URL) {
        try! Data((prefix + master).utf8).write(to: url.HEAD, options: .atomic)
    }
    
    static func checkout(_ url: URL, path: [String], name: String) {
        try! Data((prefix + path.joined(separator: "/") + "/" + name).utf8).write(to: url.HEAD, options: .atomic)
    }
}
