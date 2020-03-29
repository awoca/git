import XCTest
@testable import Git

final class IgnoreTests: Tests {
    func testEmpty() {
        XCTAssertTrue(File.contents(url).isEmpty)
    }
    
    func testGitFolder() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertTrue(File.contents(self.url).isEmpty)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
