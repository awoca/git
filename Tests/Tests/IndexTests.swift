import XCTest
@testable import Git

final class IndexTests: Tests {
    func testNew() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) {
            XCTAssertTrue($0.status.index.isEmpty)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
