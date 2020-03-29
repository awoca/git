import XCTest
@testable import Git

final class ContentTests: Tests {
    func testEmpty() {
        XCTAssertTrue(File.contents(url).isEmpty)
    }
    
    func testFile() {
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("file.txt"))
        XCTAssertEqual("file.txt", File.contents(url).first)
    }
    
    func testDirectory() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent("lorem"), withIntermediateDirectories: false)
        print(File.contents(url))
        XCTAssertTrue(File.contents(url).isEmpty)
    }
    
    func testFileInSubdirectory() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent("lorem"), withIntermediateDirectories: false)
        try! Data("hello world".utf8).write(to: url.appendingPathComponent("fileA.txt"))
        try! Data("world hello".utf8).write(to: url.appendingPathComponent("lorem/fileB.txt"))
        let contents = File.contents(url)
        XCTAssertTrue(contents.contains("fileA.txt"))
        XCTAssertTrue(contents.contains("lorem/fileB.txt"))
    }
}
