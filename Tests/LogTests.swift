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
                XCTAssertNil($0?.parent.first)
                XCTAssertEqual("first commit", $0?.message)
                XCTAssertEqual("file.txt", self.repository.index.items.first?.path)
                XCTAssertEqual(40, (try? String(decoding: Data(contentsOf: self.url.appendingPathComponent(".git/refs/heads/master")), as: UTF8.self))?.count)
                let commit = Commit(self.url, id: .init((try? String(decoding: Data(contentsOf: self.url.appendingPathComponent(".git/refs/heads/master")), as: UTF8.self)) ?? ""))
                XCTAssertEqual("6c6a54b9bfc715ac30dae119b85cdad3df15e5b2", commit.tree)
                XCTAssertEqual("Cez Berenjena", commit.author.name)
                XCTAssertEqual("cez@berenjena.com", commit.author.email)
                XCTAssertLessThan(1, commit.author.date)
                XCTAssertEqual(commit.author, commit.committer)
                XCTAssertEqual("first commit", commit.message)
                XCTAssertTrue(commit.parent.isEmpty)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testSecondCommit() {
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("file.txt"))
        try! Data("lorem ipsum".utf8).write(to: url.appendingPathComponent("another.txt"))
        let expect = expectation(description: "")
        git.create(url).sink {
            self.repository = $0
            self.repository.log.commit(["file.txt"], message: "first commit")
            self.repository.log.commit(["another.txt"], message: "second commit")
            self.repository.log.history.sink {
                XCTAssertEqual("first commit", $0?.parent.first?.message)
                XCTAssertEqual("second commit", $0?.message)
                XCTAssertEqual("313b11209e780998414abc1de1292143a1a45b5c", $0?.tree)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
