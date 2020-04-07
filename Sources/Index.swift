import Foundation

final class Index {
    struct Item: Hashable {
        var hash = ""
        var path = ""
        var size = UInt32()
        var device = UInt32()
        var inode = UInt32()
        var user = UInt32()
        var group = UInt32()
        var created = UInt32()
        var modified = UInt32()
        var mode = UInt32(33188)
        var conflicts = false
        
        func hash(into: inout Hasher) { into.combine(path) }
        static func == (lhs: Self, rhs: Self) -> Bool { lhs.path == rhs.path }
    }
    
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
            item.path = data.path()
            items.insert(item)
        }
    }
    
    init(_ url: URL) {
        self.url = url
    }
    
    func save(_ adding: Set<String>) -> Id {
        var items = self.items
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
    
    private func save(_ items: Set<Item>) {
        var data = Data()
        data.append(contentsOf: "DIRC".utf8)
        data.append(.init(bytes: UInt32(2)))
        data.append(.init(bytes: UInt32(items.count)))
        items.sorted { $0.path.caseInsensitiveCompare($1.path) != .orderedDescending }.forEach {
            data.append(.init(bytes: $0.created))
            data.append(.init(bytes: UInt32()))
            data.append(.init(bytes: $0.device))
            data.append(.init(bytes: $0.inode))
            data.append(.init(bytes: $0.mode))
            data.append(.init(bytes: $0.user))
            data.append(.init(bytes: $0.group))
            data.append(.init(bytes: $0.size))
            data.append(.init(bytes: $0.device))
        }
        
        serial.string("DIRC")
        serial.number(UInt32(version))
        serial.number(UInt32(entries.count))
        entries.sorted(by: { $0.url.path.compare($1.url.path, options: .caseInsensitive) != .orderedDescending }).forEach {
            serial.date($0.created)
            serial.date($0.modified)
            serial.number(UInt32($0.device))
            serial.number(UInt32($0.inode))
            serial.number(UInt32($0.mode))
            serial.number(UInt32($0.user))
            serial.number(UInt32($0.group))
            serial.number(UInt32($0.size))
            serial.hex($0.id)
            serial.number(UInt8(0))
            
            let name = String($0.url.path.dropFirst(url.path.count + 1))
            var size = name.count
            serial.number(UInt8(size))
            serial.nulled(name)
            while (size + 7) % 8 != 0 {
                serial.string("\u{0000}")
                size += 1
            }
        }
        serial.hash()
        try! serial.data.write(to: url.appendingPathComponent(".git/index"), options: .atomic)
    }
}
