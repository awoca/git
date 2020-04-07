import Foundation

extension Data {
    init<T>(bytes: T) {
        var bytes = bytes
        self.init(bytes: &bytes, count: MemoryLayout<T>.size)
    }
    
    mutating func uInt32() -> UInt32 {
        .init(Int(hex(4), radix: 16)!)
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
    
    func conflicts() -> Bool {
        var byte = first!
        byte >>= 2
        if (byte & 0x01) == 1 {
            return true
        }
        byte >>= 1
        if (byte & 0x01) == 1 {
            return true
        }
        return false
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
