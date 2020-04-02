import XCTest
@testable import Git

final class TreeTests: Tests {
    func testEmpty() {
        let tree = Tree.scan(url)
        XCTAssertTrue(tree.avoid.isEmpty)
        XCTAssertTrue(tree.save.isEmpty)
    }
    
    func testNewRepository() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            let tree = Tree.scan(self.url)
            XCTAssertTrue(tree.avoid.isEmpty)
            XCTAssertTrue(tree.save.isEmpty)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewRepositoryOneFile() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("file.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            let tree = Tree.scan(self.url)
            XCTAssertEqual(1, tree.avoid.count)
            XCTAssertTrue(tree.save.isEmpty)
            XCTAssertEqual("95d09f2b10159347eece71399a7e2e907ea3df4f", tree.avoid.first?.id.hash)
            XCTAssertEqual("file.txt", tree.avoid.first?.name)
            XCTAssertEqual(.blob, tree.avoid.first?.category)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
