import XCTest
@testable import Git

final class BranchTests: Tests {
    func testInvalid() {
        XCTAssertTrue(_Branch.current(url) is InvalidBranch)
    }
    
    func testMaster() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: false)
        try! Data("ref: refs/heads/master".utf8).write(to: url.appendingPathComponent(".git/HEAD"), options: .atomic)
        XCTAssertTrue(_Branch.current(url) is MasterBranch)
    }
    
    func testDirtyMaster() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: false)
        try! Data("ref: refs/heads/master\n\n\n\n".utf8).write(to: url.appendingPathComponent(".git/HEAD"), options: .atomic)
        XCTAssertTrue(_Branch.current(url) is MasterBranch)
    }
    
    func testNamed() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: false)
        try! Data("ref: refs/heads/life/facts/avocado-is-tasty".utf8).write(to: url.appendingPathComponent(".git/HEAD"), options: .atomic)
        let named = _Branch.current(url) as? NamedBranch
        XCTAssertEqual("avocado-is-tasty", named?.name)
        XCTAssertEqual("life", named?.path.first)
        XCTAssertEqual("facts", named?.path.last)
    }
    
    func testCheckoutMaster() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: false)
        _Branch.checkoutMaster(url)
        XCTAssertTrue(_Branch.current(url) is MasterBranch)
    }
    
    func testCheckout() {
        try! FileManager.default.createDirectory(at: url.appendingPathComponent(".git"), withIntermediateDirectories: false)
        _Branch.checkout(url, path: ["hello", "world"], name: "guacamole-for-dinner")
        let named = _Branch.current(url) as? NamedBranch
        XCTAssertEqual("guacamole-for-dinner", named?.name)
        XCTAssertEqual("hello", named?.path.first)
        XCTAssertEqual("world", named?.path.last)
    }
}
