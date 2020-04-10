import XCTest
@testable import Git

final class BranchTests: Tests {
    var repository: Repository!
    
    func testDirtyMaster() {
        let expect = expectation(description: "")
        git.create(url).sink {
            self.repository = $0
            try! Data("ref: refs/heads/master\n\n\n\n".utf8).write(to: self.url.appendingPathComponent(".git/HEAD"), options: .atomic)
            self.repository.branch.sink {
                XCTAssertEqual("master", $0)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testPathAndName() {
        let expect = expectation(description: "")
        git.create(url).sink {
            self.repository = $0
            self.repository.branch.sink { _ in
                try! Data("ref: refs/heads/life/facts/avocado-is-tasty".utf8).write(to: self.url.appendingPathComponent(".git/HEAD"), options: .atomic)
                self.repository.branch.sink {
                    XCTAssertEqual("life/facts/avocado-is-tasty", $0)
                    expect.fulfill()
                }.store(in: &self.subs)
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
