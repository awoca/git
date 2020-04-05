import Foundation

extension Data {
    init<T>(bytes: T) {
        var bytes = bytes
        self.init(bytes: &bytes, count: MemoryLayout<T>.size)
    }
}
