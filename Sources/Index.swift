import Foundation

final class Index {
    private let url: URL
    
    var items: Set<Item> {
        guard var data = try? Data(contentsOf: url.index) else { return [] }
        data = data.advanced(by: 8)
        return (0 ..< data.uInt32()).reduce(into: []) { items, _ in
            var item = Item()
            item.created = data.uInt32()
            data = data.advanced(by: 4)
            item.modified = data.uInt32()
            data = data.advanced(by: 4)
            item.device = data.uInt32()
            item.inode = data.uInt32()
            item.mode = data.uInt32()
            item.user = data.uInt32()
            item.group = data.uInt32()
            item.size = data.uInt32()
            item.hash = data.hex(20)
            item.conflicts = data.conflicts()
//            item.url = url.appendingPathComponent(try parse.name())
            items.insert(item)
        }
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
        var size = UInt32()
        var device = UInt32()
        var inode = UInt32()
        var user = UInt32()
        var group = UInt32()
        var mode = UInt32(33188)
        var conflicts = false
        var created = UInt32()
        var modified = UInt32()
        
        func hash(into: inout Hasher) {
            into.combine(path)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.path == rhs.path
        }
    }
}
