import Foundation

struct Tree {
    static func save(_ url: URL, index: [Indexed]) -> Id {
        var items = Set<Item>()
        File.contents(url).forEach {
            items.insert(.init(.blob, .init(""), $0))
        }
        return .init("")
    }
    
    private init() {
        
    }
    
    struct Item: Hashable {
        let category: Category
        let id: Id
        let name: String
        
        init(_ category: Category, _ id: Id, _ name: String) {
            self.category = category
            self.id = id
            self.name = name
        }
        
        func hash(into: inout Hasher) {
            into.combine(id)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    enum Category: String {
        case
        unknown,
        blob = "100644",
        exec = "100755",
        tree = "40000"
    }
}
