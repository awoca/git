import Foundation
import CryptoKit

final class Hash {
    class func file(_ url: URL) -> Pack {
        blob(try! .init(contentsOf: url))
    }
    
    class func tree(_ data: Data) -> Pack {
        .init("tree", data: data)
    }
    
    private class func blob(_ data: Data) -> Pack {
        .init("blob", data: data)
    }
    
    struct Pack {
        let object: Data
        let hash: String
        let size: Int
        
        fileprivate init(_ prefix: String, data: Data) {
            size = data.count
            object = (prefix + " \(data.count)\u{0000}").utf8 + data
            hash = Insecure.SHA1.hash(data: object).compactMap { .init(format: "%02hhx", $0) }.joined()
        }
    }
}
