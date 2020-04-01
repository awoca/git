import XCTest
@testable import Git

final class TreeTests: Tests {
    func testEmpty() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            XCTAssertTrue(self.repository.status.tree.items.isEmpty)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
