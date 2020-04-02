import XCTest
@testable import Git

final class TreeTests: Tests {
    func testEmpty() {
        XCTAssertTrue(Tree(url).items.isEmpty)
    }
    
    func testNewRepository() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertTrue(Tree(self.url).items.isEmpty)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
