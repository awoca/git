import Foundation

final class Index {
    struct Item: Hashable {
        var id = Id("")
        var path = ""
        var size = UInt32()
        var device = UInt32()
        var inode = UInt32()
        var user = UInt32()
        var group = UInt32()
        var mode = UInt32(33188)
        var created = Timestamp()
        var modified = Timestamp()
        
        func hash(into: inout Hasher) { into.combine(path) }
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.path == rhs.path }
    }
    
    struct Timestamp {
        var time = UInt32()
        var millis = UInt32()
    }
    
    weak var repository: Repository!
    
    var items: Set<Item> {
        guard var data = try? Data(contentsOf: repository.url.index) else { return [] }
        data = data.advanced(by: 8)
        return (0 ..< data.uInt32()).reduce(into: []) { items, _ in
            var item = Item()
            item.created.time = data.uInt32()
            item.created.millis = data.uInt32()
            item.modified.time = data.uInt32()
            item.modified.millis = data.uInt32()
            item.device = data.uInt32()
            item.inode = data.uInt32()
            item.mode = data.uInt32()
            item.user = data.uInt32()
            item.group = data.uInt32()
            item.size = data.uInt32()
            item.id = .init(data.hex(20))
            item.path = data.path()
            items.insert(item)
        }
    }
    
    func save(_ adding: Set<String>) -> Id {
        var items = self.items
        var tree = Data()
        File.contents(repository.url).forEach { path in
            var item: Item?
            if adding.contains(path) {
                let pack = Hash.file(repository.url.appendingPathComponent(path))
                item = Item()
                item!.id = pack.id
                item!.size = .init(pack.size)
                item!.path = path
                item!.created.time = .init(Date().timeIntervalSince1970)
                item!.modified.time = item!.created.time
                items.remove(item!)
                items.insert(item!)
                pack.save(repository.url)
            } else {
                item = items.first { $0.path == path }
            }
            guard item != nil else { return }
            tree.append(contentsOf: (Tree.Category.blob.rawValue + " " + path).utf8)
            tree.null()
            tree.hex(item!.id.hash)
        }
        let pack = Hash.tree(tree)
        pack.save(repository.url)
        save(items)
        return pack.id
    }
    
    private func save(_ items: Set<Item>) {
        var data = Data()
        data.append(contentsOf: "DIRC".utf8)
        data.uInt32(.init(2))
        data.uInt32(.init(items.count))
        items.sorted { $0.path.caseInsensitiveCompare($1.path) != .orderedDescending }.forEach {
            data.uInt32(.init($0.created.time))
            data.uInt32(.init($0.created.millis))
            data.uInt32(.init($0.modified.time))
            data.uInt32(.init($0.modified.millis))
            data.uInt32(.init($0.device))
            data.uInt32(.init($0.inode))
            data.uInt32(.init($0.mode))
            data.uInt32(.init($0.user))
            data.uInt32(.init($0.group))
            data.uInt32(.init($0.size))
            data.hex($0.id.hash)
            data.append(0)
            data.append(.init($0.path.count))
            data.append(contentsOf: $0.path.utf8)
            data.null()
            var size = $0.path.count
            while (size + 7) % 8 != 0 {
                data.null()
                size += 1
            }
        }
        data.append(contentsOf: Hash.sha1(data))
        try! data.write(to: repository.url.index, options: .atomic)
    }
}
