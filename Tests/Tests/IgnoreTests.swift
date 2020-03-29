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
    
    func testMatchesGit() {
        let shouldContain = [
            ".gita",
            "a.git",
            "halo/so.gita"]
        shouldContain.forEach(create(_:))
        let contents = File.contents(self.url)
        shouldContain.forEach {
            XCTAssertTrue(contents.contains($0), $0)
        }
    }
    
    func testMatchesFolder() {
        ignore([""])
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
