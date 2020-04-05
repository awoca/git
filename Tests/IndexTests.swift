import XCTest
@testable import Git

final class IndexTests: Tests {
    private var index: Index!
    
    override func setUp() {
        super.setUp()
        index = .init(url)
    }
    
    func testLoad() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: true)
        try! Data(base64Encoded: index0)!.write(to: url.appendingPathComponent(".git/index"))
        let items = index.items
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("afile.json", items.first?.path)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", items.first?.hash)
        XCTAssertEqual(12, items.first?.size)
        XCTAssertEqual(1554190306, items.first?.created.timeIntervalSince1970)
        XCTAssertEqual(1554190306, items.first?.modified.timeIntervalSince1970)
        XCTAssertEqual(16777220, items.first?.device)
        XCTAssertEqual(10051196, items.first?.inode)
        XCTAssertEqual(502, items.first?.user)
        XCTAssertEqual(20, items.first?.group)
    }
    
    func testSave() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: true)
        try! Data(base64Encoded: index0)!.write(to: url.appendingPathComponent(".git/index"))
        _ = index.save([])
        XCTAssertEqual(index0, try? Data(contentsOf: url.appendingPathComponent(".git/index")).base64EncodedString())
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

private let index0 = "RElSQwAAAAIAAAABXKMP4g4nUXhcow/iDidReAEAAAQAmV58AACBpAAAAfYAAAAUAAAADDsY5RLbp55MgwDdCK6zf45yi42tAAphZmlsZS5qc29uAAAAAAAAAABIOjvvZZYKFlHYMWjy0VATl2F0cg=="
