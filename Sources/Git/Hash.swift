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
        let id: Id
        let object: Data
        let size: Int
        private let header = Data([0x78, 0x1])
        private let prime = UInt32(65521)
        
        fileprivate init(_ prefix: String, data: Data) {
            size = data.count
            object = (prefix + " \(data.count)\u{0000}").utf8 + data
            id = .init(Insecure.SHA1.hash(data: object).compactMap { .init(format: "%02hhx", $0) }.joined())
        }
        
        func save(_ url: URL) {
            let location = url.objects.appendingPathComponent(id.head).appendingPathComponent(id.tail)
            guard !location.exists else { return }
            File.create(location.deletingLastPathComponent())
            try! (header + ((object as NSData).compressed(using: .zlib)) + adler32).write(to: location, options: .atomic)
        }
        
        private var adler32: Data {
            var s1 = UInt32(1)
            var s2 = UInt32()
            object.forEach {
                s1 = (s1 + .init($0)) % prime
                s2 = (s2 + s1) % prime
            }
            return .init(bytes: (s2 << 16 | s1).bigEndian)
        }
    }
}
