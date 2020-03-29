import Foundation

public protocol Report { }

public struct Clean: Report { }

public struct Changed: Report {
    public let items: Set<Item>
    
    public enum Status {
        case
        untracked,
        added,
        modified,
        deleted
    }
    
    public struct Item: Hashable {
        let status: Status
        let path: String
        
        public func hash(into: inout Hasher) {
            into.combine(path)
        }
        
        public static func != (lhs: Self, rhs: Self) -> Bool {
            lhs.path == rhs.path
        }
    }
}
