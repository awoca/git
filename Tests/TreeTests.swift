import XCTest
@testable import Git

final class TreeTests: Tests {
    func testEmpty() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: true)
        XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Index(url).save([]).hash)
        XCTAssertEqual("eAErKUpNVTBgAAAKLAIB",
                       try? Data(contentsOf: self.url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904")).base64EncodedString())
    }
    
    func testNewRepository() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Index(self.url).save([]).hash)
            XCTAssertEqual("eAErKUpNVTBgAAAKLAIB",
                           try? Data(contentsOf: self.url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904")).base64EncodedString())
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewRepositoryOneFileIgnored() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertEqual("4b825dc642cb6eb9a060e54bf8d69288fbee4904", Index(self.url).save([]).hash)
            XCTAssertEqual("eAErKUpNVTBgAAAKLAIB",
                           try? Data(contentsOf: self.url.appendingPathComponent(".git/objects/4b/825dc642cb6eb9a060e54bf8d69288fbee4904")).base64EncodedString())
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testNewRepositoryOneFile() {
        let expect = expectation(description: "")
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("myfile.txt"))
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertEqual("007a8ffce38213667b95957dc505ef30dac0248d", Index(self.url).save(["myfile.txt"]).hash)
            XCTAssertEqual("eAErKUpNVTC2YDA0MDAzMVHIrUzLzEnVK6koYZh6Yb62gOhk93fnCi1n1elNqFt83x8AXz4RWA==",
                           try? Data(contentsOf: self.url.appendingPathComponent(".git/objects/00/7a8ffce38213667b95957dc505ef30dac0248d")).base64EncodedString())
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
}
