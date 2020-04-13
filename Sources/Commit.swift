import Foundation

public final class Commit: Hashable {
    public struct Author: Equatable {
        public let name: String
        public let email: String
        public let date: Int
        
        fileprivate init(_ string: String) {
            name = string.components(separatedBy: " <").first!.components(separatedBy: " ").dropFirst().joined(separator: " ")
            email = string.components(separatedBy: "<").last!.components(separatedBy: ">").first!
            date = Int(string.components(separatedBy: "> ").last!.components(separatedBy: " ").first!)!
        }
    }
    
    public let author: Author
    public let committer: Author
    public let message: String
    public let parent: Set<Commit>
    let id: Id
    let tree: String
    
    init(_ url: URL, id: Id) {
        let sections = String(decoding: Hash.object(url.object(id)), as: UTF8.self).components(separatedBy: "\n\n")
        let lines = sections.first!.components(separatedBy: "\n")
        self.id = id
        tree = .init(lines.first!.suffix(40))
        author = .init(lines.first { $0.hasPrefix("author") }!)
        committer = .init(lines.first { $0.hasPrefix("committer") }!)
        message = sections.dropFirst().joined(separator: "\n\n")
        parent = lines.filter { $0.hasPrefix("parent") }.reduce(into: []) {
            let id = Id(.init($1.suffix(40)))
            guard url.object(id).exists else { return }
            $0.insert(.init(url, id: id))
        }
    }
    
    public func hash(into: inout Hasher) {
        into.combine(id)
    }
    
    public static func == (lhs: Commit, rhs: Commit) -> Bool {
        lhs.id == rhs.id
    }
}
