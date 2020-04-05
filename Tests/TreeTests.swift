import XCTest
@testable import Git

final class TreeTests: Tests {
    func testEmpty() {
        XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Index(url).save([]).hash)
        XCTAssertEqual(15, try? Data(contentsOf: url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904")).count)
    }
    
    func testNewRepository() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Index(self.url).save([]).hash)
            XCTAssertEqual(15, try? Data(contentsOf: self.url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904")).count)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewRepositoryOneFileIgnored() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Index(self.url).save([]).hash)
            XCTAssertEqual(15, try? Data(contentsOf: self.url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904")).count)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewRepositoryOneFile() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertEqual("007a8ffce38213667b95957dc505ef30dac0248d", Index(self.url).save(["myfile.txt"]).hash)
            XCTAssertEqual(55, try? Data(contentsOf: self.url.appendingPathComponent(".git/objects/00/7a8ffce38213667b95957dc505ef30dac0248d")).count)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
