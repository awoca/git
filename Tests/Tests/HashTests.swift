import XCTest
@testable import Git

final class HashTests: Tests {
    func testFile() {
        let file = url.appendingPathComponent("file.json")
        try! Data("hello world\n".utf8).write(to: file)
        XCTAssertEqual("3b18e512dba79e4c8300dd08aeb37f8e728b8dad", Hash.file(file).hash)
    }
    
    func testTree() {
        XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Hash.tree(.init()).hash)
    }
}
