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
    public private(set) var parent = [String : Commit?]()
    private(set) var tree = [String : Tree?]()
    
    init(_ url: URL) {
        var components = String(decoding: Hash.object(url), as: UTF8.self).components(separatedBy: "\n")
        tree.updateValue(nil, forKey: .init(components.removeFirst().suffix(40)))
        var component = components.removeFirst()
        while !component.isEmpty {
            switch component.prefix(6) {
            case "parent": parent.updateValue(nil, forKey: .init(component.suffix(40)))
            case "author": break
            case "commit": break
            case "gpgsig": break
            default: break
            }
            component = components.removeFirst()
        }
        message = components.joined(separator: "\n")
        author = .init(name: "", email: "", date: 0)
        commiter = .init(name: "", email: "", date: 0)
        privacy = ""
    }
}
