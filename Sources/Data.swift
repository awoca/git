import Foundation

extension Data {
    init<T>(bytes: T) {
        var bytes = bytes
        self.init(bytes: &bytes, count: MemoryLayout<T>.size)
    }
    
    init(_ url: URL) {
        try! self.init(contentsOf: url)
    }
    
    mutating func uInt32() -> UInt32 {
        UInt32(hex(4), radix: 16)!
    }
    
    mutating func string(_ length: Int) -> String {
        let result = String(decoding: subdata(in: 0 ..< length), as: UTF8.self)
        self = advanced(by: length)
        return result
    }
    
    mutating func hex(_ size: Int) -> String {
        let result = subdata(in: 0 ..< size).map { .init(format: "%02hhx", $0) }.joined()
        self = advanced(by: size)
        return result
    }
    
    mutating func path() -> String {
        let version = self.version()
        let length = Int(hex(1), radix: 16)!
        if version == 3 {
            self = advanced(by: 2)
        }
        let result = string(length)
        clean()
        return result
    }
    
    mutating func null() {
        append(contentsOf: "\u{0000}".utf8)
    }
    
    mutating func uInt32(_ reversing: UInt32) {
        Swift.withUnsafeBytes(of: reversing) {
            append(contentsOf: $0.reversed())
        }
    }
    
    mutating func hex(_ string: String) {
        append(contentsOf: stride(from: 0, to: string.count, by: 2).map {
            string[string.index(string.startIndex, offsetBy: $0) ... string.index(string.startIndex, offsetBy: $0 + 1)]
        }.map {
            UInt8($0, radix: 16)!
        })
    }
    
    private mutating func version() -> Int {
        let result = (first! >> 1 & 0x01) == 1 ? 3 : 2
        self = advanced(by: 1)
        return result
    }
    
    private mutating func clean() {
        while .init(decoding: [first!], as: UTF8.self) == "\u{0000}" {
            self = advanced(by: 1)
        }
    }
}
