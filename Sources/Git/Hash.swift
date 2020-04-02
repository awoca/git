import Foundation
import CryptoKit

final class Hash {
    class func file(_ url: URL) -> Pack {
        blob(try! .init(contentsOf: url))
    }
    
    class func blob(_ data: Data) -> Pack {
        .init("blob \(data.count)\u{0000}".utf8 + data)
    }
    
    struct Pack {
        let object: Data
        let hash: String
        
        fileprivate init(_ object: Data) {
            hash = Insecure.SHA1.hash(data: object).compactMap { .init(format: "%02hhx", $0) }.joined()
            self.object = object
        }
    }
}
