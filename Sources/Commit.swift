import Foundation

public final class Commit {
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
    public private(set) var parent = [String : Commit?]()
    private(set) var tree = [String : Tree?]()
    
    init(_ url: URL) {
        let middle = String(decoding: Hash.object(url), as: UTF8.self).components(separatedBy: "\n\n")
        let lines = middle.first!.components(separatedBy: "\n")
        message = middle.dropFirst().joined(separator: "\n\n")
        tree.updateValue(nil, forKey: .init(lines.first!.suffix(40)))
        parent = .init(uniqueKeysWithValues: lines.filter { $0.hasPrefix("parent") }.map { (.init($0.suffix(40)), nil) })
        author = .init(lines.first { $0.hasPrefix("author") }!)
        committer = .init(lines.first { $0.hasPrefix("committer") }!)
    }
}
