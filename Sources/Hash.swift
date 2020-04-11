import Foundation
import CryptoKit

final class Hash {
    class func sha1(_ data: Data) -> Insecure.SHA1.Digest {
        Insecure.SHA1.hash(data: data)
    }
    
    class func file(_ url: URL) -> Pack {
        blob(.init(url))
    }
    
    class func tree(_ data: Data) -> Pack {
        .init("tree", data: data)
    }
    
    class func object(_ url: URL) -> Data {
        try! (Data(url).advanced(by: 2) as NSData).decompressed(using: .zlib) as Data
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
            id = .init(Hash.sha1(object).compactMap { .init(format: "%02hhx", $0) }.joined())
        }
        
        func save(_ url: URL) {
            let location = url.object(id)
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
