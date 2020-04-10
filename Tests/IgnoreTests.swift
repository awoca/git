import XCTest
@testable import Git

final class IgnoreTests: Tests {
    func testGitFolder() {
        let expect = expectation(description: "")
        git.create(url).sink { _ in
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
        yes.forEach(create)
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
        yes.forEach(create)
        no.forEach(create)
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
        yes.forEach(create)
        no.forEach(create)
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
        yes.forEach(create)
        no.forEach(create)
        let contents = File.contents(url)
        XCTAssertEqual(3, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
        no.forEach { XCTAssertFalse(contents.contains($0), $0) }
    }
    
    func testTwoAsterisksLeading() {
        ignore(["**/file"])
        let yes = [
            "some/file.txt",
            "file.txt"]
        let no = [
            "file/something.txt",
            "avocado/file/something.txt",
            "avocado/something/file"]
        yes.forEach(create)
        no.forEach(create)
        let contents = File.contents(url)
        XCTAssertEqual(3, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
        no.forEach { XCTAssertFalse(contents.contains($0), $0) }
    }
    
    func testTwoAsterisksTrailing() {
        ignore(["file/**"])
        let yes = [
            "some/file",
            "alpha/file/some"]
        let no = [
            "file/some",
            "file/other"]
        yes.forEach(create)
        no.forEach(create)
        let contents = File.contents(url)
        XCTAssertEqual(3, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
        no.forEach { XCTAssertFalse(contents.contains($0), $0) }
    }
    
    func testAsteriskLeading() {
        ignore(["*some"])
        let yes = [
            "something",
            "alpha/somea/someb"]
        let no = [
            "file/some",
            "file/awesome",
            "some/file",
            "some/other",
            "awesome/file",
            "awesome/other"]
        yes.forEach(create)
        no.forEach(create)
        let contents = File.contents(url)
        XCTAssertEqual(3, contents.count)
        yes.forEach { XCTAssertTrue(contents.contains($0), $0) }
        no.forEach { XCTAssertFalse(contents.contains($0), $0) }
    }
    
    func testAsteriskTrailing() {
        ignore(["some*"])
        let yes = [
            "thingsome",
            "alpha/awesome/basome"]
        let no = [
            "file/some",
            "file/someawe",
            "some/file",
            "some/other",
            "someawe/file",
            "someawe/other"]
        yes.forEach(create)
        no.forEach(create)
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
