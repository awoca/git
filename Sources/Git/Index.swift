import Foundation

final class Index {
    private let url: URL
    
    var items: Set<Item> {
        []
    }
    
    init(_ url: URL) {
        self.url = url
    }
    
    func save(_ adding: Set<String>) -> Id {
        adding.forEach {
            let pack = Hash.file(url.appendingPathComponent($0))
            pack.save(url)
        }
        var tree = Set<Tree.Item>()
        File.contents(url).filter(adding.contains).forEach {
            tree.insert(.init(.blob, .init(""), $0))
        }
        let pack = Hash.tree(.init())
        pack.save(url)
        return pack.id
    }
    
    struct Item: Hashable {
        var hash = ""
        var path = ""
        var size = 0
        var device = 0
        var inode = 0
        var user = 0
        var group = 0
        var mode = 33188
        var conflicts = false
        var created = Date()
        var modified = Date()
        
        func hash(into: inout Hasher) {
            into.combine(path)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.path == rhs.path
        }
    }
}
