import XCTest
@testable import Git

final class StatusTests: Tests {
    var repository: Repository!
    
    func testClean() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            DispatchQueue.global(qos: .background).async {
                self.repository.status.sink {
                    XCTAssertEqual(.main, Thread.current)
                    XCTAssertTrue($0.added.isEmpty)
                    XCTAssertTrue($0.untracked.isEmpty)
                    XCTAssertTrue($0.deleted.isEmpty)
                    XCTAssertTrue($0.modified.isEmpty)
                    expect.fulfill()
                }.store(in: &self.subs)
            }
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewFileBeforeCreate() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("file.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            self.repository.status.sink {
                XCTAssertEqual("file.txt", $0.untracked.first)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewFileAfterCreate() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            self.repository.status.sink {
                XCTAssertEqual("file.txt", $0.untracked.first)
                expect.fulfill()
            }.store(in: &self.subs)
            try! Data("hello world".utf8).write(to: self.url.appendingPathComponent("file.txt"))
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testAdded() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            try! Data("hello world".utf8).write(to: self.url.appendingPathComponent("file.txt"))
            _ = Index(self.url).save(["file.txt"])
            self.repository.status.sink {
                XCTAssertEqual("file.txt", $0.added.first)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
