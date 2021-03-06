import XCTest
import Combine
import Git

class Tests: XCTestCase {
    var subs = Set<AnyCancellable>()
    private(set) var git: Git!
    private(set) var url: URL!
    
    override func setUp() {
        git = .init()
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
