import Foundation

public final class Commit {
    public struct Author: Equatable {
        public let name: String
        public let email: String
        public let date: Int
    }
    
    public let author: Author
    public let commiter: Author
    public let message: String
    public let privacy: String
    public private(set) var parent: [String : Commit?]
    private(set) var tree: [String : Tree?]
    
    init(_ url: URL, id: Id) {
        author = .init(name: "", email: "", date: 0)
        commiter = .init(name: "", email: "", date: 0)
        parent = [:]
        tree = [:]
        message = ""
        privacy = ""
    }
}
