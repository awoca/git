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
            item.path = data.path()
            items.insert(item)
        }
        
    }
    
    init(_ url: URL) {
        self.url = url
    }
    
    func save(_ adding: Set<String>) -> Id {
        var items = self.items
        save(items)
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
    
    private let map = [
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
        0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
        0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
    ] as [UInt8]
    
    private func save(_ items: Set<Item>) {
        
        
        var data = Data()
        
        func number<T: BinaryInteger>(_ number: T) { withUnsafeBytes(of: number) { data.append(contentsOf: $0.reversed()) } }
        
        data.append(contentsOf: "DIRC".utf8)
        number(UInt32(2))
        number(UInt32(1))
        items.sorted { $0.path.caseInsensitiveCompare($1.path) != .orderedDescending }.forEach {
            number(UInt32($0.created))
            number(UInt32(0))
            number(UInt32($0.modified))
            number(UInt32(0))
            number(UInt32($0.device))
            number(UInt32($0.inode))
            number(UInt32($0.mode))
            number(UInt32($0.user))
            number(UInt32($0.group))
            number(UInt32($0.size))
            data.append(contentsOf: hex($0.hash))
            number(UInt8(0))
            number(UInt8($0.path.count))
            data.append(contentsOf: $0.path.utf8)
            data.addNull()
            var size = $0.path.count
            while (size + 7) % 8 != 0 {
                data.addNull()
                size += 1
            }
        }
        let a = Hash.sha1(data)
        print(data.count)
        data.append(contentsOf: a)
        print(data.count)
        try! data.write(to: url.index, options: .atomic)
    }
    
    func hex(_ string: String) -> [UInt8] {
        string.utf8.reduce(into: ([UInt8](), [UInt8]())) {
            $0.0.append(map[Int($1 & 0x1F ^ 0x10)])
            if $0.0.count == 2 {
                $0.1.append($0.0[0] << 4 | $0.0[1])
                $0.0 = []
            }
        }.1
    }
}
