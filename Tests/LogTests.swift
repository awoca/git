import XCTest
@testable import Git

final class LogTests: Tests {
    var repository: Repository!
    
    override func setUp() {
        super.setUp()
        Git.credentials.name = "Cez Berenjena"
        Git.credentials.email = "cez@berenjena.com"
    }
    
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
            self.repository.log.history.sink {
                XCTAssertEqual("first commit", $0?.message)
                XCTAssertEqual("file.txt", self.repository.index.items.first?.path)
                XCTAssertNil($0?.parent)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
