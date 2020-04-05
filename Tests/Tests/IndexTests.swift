import XCTest
@testable import Git

final class IndexTests: Tests {
    private var index: Index!
    
    override func setUp() {
        super.setUp()
        index = .init(url)
    }
    
    func testAdd() {
        let file = url.appendingPathComponent("file.json")
        try! Data("hello world\n".utf8).write(to: file)
        _ = index.save(["file.json"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad").path))
        let items = index.items
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", items.first?.hash)
        XCTAssertEqual("file.json", items.first?.path)
    }
}
