import Foundation

struct Tree {
    var avoid = Set<Item>()
    var save = Set<Item>()
    
    init(_ url: URL) {
        
    }
    
    struct Item: Hashable {
        let hash: String
        let name: String
        let category: Category
        
        init(_ hash: String, _ name: String, _ category: Category) {
            self.hash = hash
            self.name = name
            self.category = category
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
