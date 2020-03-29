import XCTest
import Git

final class StatusTests: Tests {
    func testClean() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) { repository in
            repository.status.sink {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertTrue($0 is Clean)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
