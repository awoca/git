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
    
    func testNewFileBeforeCreate() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("file.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) { repository in
            repository.status.sink {
                let changes = $0 as? Changes
                XCTAssertEqual(.untracked, changes?.items.first?.status)
                XCTAssertEqual("file.txt", changes?.items.first?.path)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewFileAfterCreate() {
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 2
        git.create(url).sink(receiveCompletion: { _ in }) { repository in
            repository.status.sink {
                if let changes = $0 as? Changes {
                    XCTAssertEqual(.untracked, changes.items.first?.status)
                    XCTAssertEqual("file.txt", changes.items.first?.path)
                }
                expect.fulfill()
            }.store(in: &self.subs)
//            try! Data("hello world".utf8).write(to: self.url.appendingPathComponent("file.txt"))
        }.store(in: &subs)
        waitForExpectations(timeout: 5)
    }
}
