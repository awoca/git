import Foundation

final class Index {
 
    
    func save(_ url: URL) -> Id {
        var items = Set<Tree.Item>()
        File.contents(url).forEach {
            items.insert(.init(.blob, .init(""), $0))
        }
        return .init("")
    }
    
    struct Item {
        var id = ""
        var path = ""
        var created = Date()
        var modified = Date()
        var size = 0
        var device = 0
        var inode = 0
        var mode = 33188
        var user = 0
        var group = 0
        var conflicts = false
    }
}
