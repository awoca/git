import Foundation

struct Tree {
    static func make(_ repository: Repository, path: String) -> Tree {
        .init()
    }
    
    var items = [Item]()
    
    private init() { }
    
    struct Item {
        let hash: String
        let path: String
        let category: Category
        
        init(_ hash: String, _ path: String, _ category: Category) {
            self.hash = hash
            self.path = path
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
