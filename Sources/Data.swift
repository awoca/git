import Foundation

extension Data {
    init<T>(bytes: T) {
        var bytes = bytes
        self.init(bytes: &bytes, count: MemoryLayout<T>.size)
    }
    
    mutating func uInt32() -> UInt32 {
        .init(Int(hex(4), radix: 16)!)
    }
    
    mutating func hex(_ size: Int) -> String {
        let result = subdata(in: 0 ..< size).map { .init(format: "%02hhx", $0) }.joined()
        self = advanced(by: size)
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
}
