import XCTest
@testable import Git

final class IndexTests: Tests {
    private var repository: Repository!
    
    override func setUp() {
        super.setUp()
        repository = .init(url)
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: true)
    }
    
    func testLoad() {
        try! Data(base64Encoded: index0)!.write(to: url.appendingPathComponent(".git/index"))
        let items = repository.index.items
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("afile.json", items.first?.path)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", items.first?.id.hash)
        XCTAssertEqual(12, items.first?.size)
        XCTAssertEqual(1554190306, items.first?.created.time)
        XCTAssertEqual(237457784, items.first?.created.millis)
        XCTAssertEqual(1554190306, items.first?.modified.time)
        XCTAssertEqual(237457784, items.first?.modified.millis)
        XCTAssertEqual(16777220, items.first?.device)
        XCTAssertEqual(10051196, items.first?.inode)
        XCTAssertEqual(502, items.first?.user)
        XCTAssertEqual(20, items.first?.group)
    }
    
    func testLoadBig() {
        try! Data(base64Encoded: index1)!.write(to: url.appendingPathComponent(".git/index"))
        XCTAssertEqual(22, repository.index.items.count)
    }
    
    func testSave() {
        try! Data(base64Encoded: index1)!.write(to: url.appendingPathComponent(".git/index"))
        _ = repository.index.save([])
        XCTAssertEqual(index1, try? Data(contentsOf: url.appendingPathComponent(".git/index")).base64EncodedString())
    }
    
    func testAdd() {
        let file = url.appendingPathComponent("file.json")
        try! Data("hello world\n".utf8).write(to: file)
        _ = repository.index.save(["file.json"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad").path))
        let items = repository.index.items
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", items.first?.id.hash)
        XCTAssertEqual("file.json", items.first?.path)
        XCTAssertEqual(12, items.first?.size)
        XCTAssertLessThan(1, items.first?.created.time ?? 0)
        XCTAssertLessThan(1, items.first?.modified.time ?? 0)
    }
    
    func testUpdate() {
        let file = url.appendingPathComponent("file.json")
        try! Data("hello world\n".utf8).write(to: file)
        _ = repository.index.save(["file.json"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/01/a59b011a48660bb3828ec72b2b08990b8cf56b").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/3b/18e512dba79e4c8300dd08aeb37f8e728b8dad").path))
        try! Data("lorem ipsum\n".utf8).write(to: file)
        _ = repository.index.save(["file.json"])
        let items = repository.index.items
        XCTAssertEqual(1, items.count)
        XCTAssertEqual("01a59b011a48660bb3828ec72b2b08990b8cf56b", items.first?.id.hash)
        XCTAssertEqual("eAFLyslPUjA0YsjJL0rNVcgsKC7N5QIARH4Gmg==",
                       try? Data(contentsOf: url.appendingPathComponent(".git/objects/01/a59b011a48660bb3828ec72b2b08990b8cf56b")).base64EncodedString())
    }
}

private let index0 = """
RElSQwAAAAIAAAABXKMP4g4nUXhcow/iDidReAEAAAQAmV58AACBpAAAAfYAAAAUAAAADDsY5RLbp55MgwDdCK6zf45yi42tAAphZmlsZS5qc29uAAAAAAAAAABIOjvvZZYKFlHYMWjy0VATl2F0cg==
"""
private let index1 = """
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
"""
