import XCTest
import Git

final class LogTests: Tests {
    var repository: Repository!
    
    func testNoCommits() {
        let expect = expectation(description: "")
        git.create(url).sink {
            self.repository = $0
            DispatchQueue.global(qos: .background).async {
                self.repository.log.sink {
                    XCTAssertEqual(.main, Thread.current)
                    XCTAssertNil($0)
                    expect.fulfill()
                }.store(in: &self.subs)
            }
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
