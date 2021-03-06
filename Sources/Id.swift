import Foundation

struct Id: Hashable {
    var head: String { .init(hash.prefix(2)) }
    var tail: String { .init(hash.dropFirst(2)) }
    let hash: String
    
    init(_ hash: String) {
        self.hash = hash
    }
    
    func hash(into: inout Hasher) {
        into.combine(hash)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hash == rhs.hash
    }
}
