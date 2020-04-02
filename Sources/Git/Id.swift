import Foundation

struct Id: Hashable {
    var head: String { .init(hash.prefix(2)) }
    var tail: String { .init(hash.dropFirst(2)) }
    let hash: String
    
    init(_ hash: String) {
        self.hash = hash
    }
}
