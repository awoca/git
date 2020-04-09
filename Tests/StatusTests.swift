import XCTest
@testable import Git

final class StatusTests: Tests {
    var repository: Repository!
    
    func testClean() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            self.repository.status.sink {
                XCTAssertEqual(.main, Thread.current)
                XCTAssertTrue($0.isEmpty)
                expect.fulfill()
                self.subs = []
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewFileBeforeCreate() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("file.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            self.repository.status.sink {
                XCTAssertEqual(.untracked, $0.first?.mode)
                XCTAssertEqual("file.txt", $0.first?.path)
                expect.fulfill()
                self.subs = []
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewFileAfterCreate() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) {
            self.repository = $0
            self.repository.status.sink {
                XCTAssertEqual(.untracked, $0.first?.mode)
                XCTAssertEqual("file.txt", $0.first?.path)
                expect.fulfill()
                self.subs = []
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
                XCTAssertEqual(.added, $0.first?.mode)
                XCTAssertEqual("file.txt", $0.first?.path)
                expect.fulfill()
                self.subs = []
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
