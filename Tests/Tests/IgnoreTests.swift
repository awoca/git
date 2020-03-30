import XCTest
@testable import Git

final class IgnoreTests: Tests {
    func testGitFolder() {
        let expect = expectation(description: "")
        git.create(url).sink(receiveCompletion: { _ in }) { _ in
            XCTAssertTrue(File.contents(self.url).isEmpty)
            expect.fulfill()
        }.store(in: &subs)
        waitForExpectations(timeout: 1)
    }
    
    func testGit() {
        let yes = [
            ".gita",
            "a.git",
            "halo/so.gita"]
        yes.forEach(create(_:))
        let contents = File.contents(url)
        XCTAssertEqual(3, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
    }
    
    func testFolder() {
        ignore(["avocado/"])
        let yes = ["some/avocado"]
        let no = [
            "avocado/something.txt",
            "hello/world/avocado/file.txt"]
        yes.forEach(create(_:))
        no.forEach(create(_:))
        let contents = File.contents(url)
        XCTAssertEqual(2, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
        no.forEach { XCTAssertFalse(contents.contains($0), $0) }
    }
    
    func testRelative() {
        ignore(["/avocado"])
        let yes = [
            "some/avocado/hello.txt",
            "avocado.txt"]
        let no = ["avocado/something.txt"]
        yes.forEach(create(_:))
        no.forEach(create(_:))
        let contents = File.contents(url)
        XCTAssertEqual(3, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
        no.forEach { XCTAssertFalse(contents.contains($0), $0) }
    }
    
    func testName() {
        ignore(["file"])
        let yes = [
            "some/file.txt",
            "file.txt"]
        let no = [
            "file/something.txt",
            "avocado/file/something.txt",
            "avocado/something/file"]
        yes.forEach(create(_:))
        no.forEach(create(_:))
        let contents = File.contents(url)
        XCTAssertEqual(3, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
        no.forEach { XCTAssertFalse(contents.contains($0), $0) }
    }
    
    private func create(_ file: String) {
        if file.contains("/") {
            try! FileManager.default.createDirectory(at: url.appendingPathComponent(file).deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        try! Data().write(to: url.appendingPathComponent(file))
    }
    
    private func ignore(_ list: [String]) {
        try! Data(list.joined(separator: "\n").utf8).write(to: url.appendingPathComponent(".gitignore"))
    }
}
