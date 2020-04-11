import XCTest
@testable import Git

final class HashTests: Tests {
    func testFile() {
        let file = url.appendingPathComponent("file.json")
        try! Data("hello world\n".utf8).write(to: file)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", Hash.file(file).id.hash)
    }
    
    func testTree() {
        XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Hash.tree(.init()).id.hash)
    }
    
    func testCommit() {
        XCTAssertEqual("5192391e9f907eeb47aa38d1c6a3a4ea78e33564", Hash.commit("""
tree 0d21e2f7f760f77ead2cb85cc128efb13f56401d
parent dc0d3343fa24e912f08bc18aaa6f664a4a020079
author Jonathan Waldman <jonathan.waldman@live.com> 1494296655 -0500
committer Jonathan Waldman <jonathan.waldman@live.com> 1494296655 -0500

Add project files.

""").id.hash)
    }
    
    func testSave() {
        let pack = Hash.tree(.init())
        pack.save(url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904").path))
    }
    
    func testDoNotOverride() {
        let file = url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904")
        try! FileManager.default.createDirectory(at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
        try! Data("lorem ipsum".utf8).write(to: file)
        let pack = Hash.tree(.init())
        pack.save(url)
        XCTAssertEqual("lorem ipsum", try! String(decoding: Data(contentsOf: file), as: UTF8.self))
    }
}
