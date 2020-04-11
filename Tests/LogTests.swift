import XCTest
import Git

final class LogTests: Tests {
    var repository: Repository!
    
    func testNoCommits() {
        let expect = expectation(description: "")
        git.create(url).sink {
            self.repository = $0
            DispatchQueue.global(qos: .background).async {
                self.repository.log.history.sink {
                    XCTAssertEqual(.main, Thread.current)
                    XCTAssertNil($0)
                    expect.fulfill()
                }.store(in: &self.subs)
            }
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testFirstCommit() {
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("file.txt"))
        let expect = expectation(description: "")
        git.create(url).sink {
            self.repository = $0
            self.repository.log.commit(["file.txt"], message: "first commit")
            self.repository.log.history.sink { _ in
//                XCTAssertEqual("first commit", $0?.message)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
