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
        let yes = [
            ".gita",
            "a.git",
            "halo/so.gita"]
        yes.forEach(create(_:))
        
        let contents = File.contents(self.url)
        
        yes.forEach {
            XCTAssertTrue(contents.contains($0), $0)
        }
    }
    
    func testMatchesFolder() {
        ignore([
            "avocado/",
            "aguacate"])
        let yes = [
            "aguacate"]
        let no = [
            "avocado/something.txt"]
        yes.forEach(create(_:))
        no.forEach(create(_:))
        
        let contents = File.contents(self.url)
        
        yes.forEach {
            XCTAssertTrue(contents.contains($0), $0)
        }
        no.forEach {
            XCTAssertFalse(contents.contains($0), $0)
        }
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
