import XCTest
import Git

final class CreateTests: Tests {
    func testCreate() {
        let expect = expectation(description: "")
        
        let root = url.appendingPathComponent(".git")
        let refs = root.appendingPathComponent("refs")
        let objects = root.appendingPathComponent("objects")
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.path))
        
        git.create(url).sink(receiveCompletion: {
            switch $0 {
            case .finished: break
            default: XCTFail()
            }
        }) {
            XCTAssertEqual(.main, Thread.current)
            XCTAssertEqual(self.url, $0.url)
            
            var dir = ObjCBool(false)
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.path, isDirectory: &dir))
            XCTAssertTrue(dir.boolValue)
            
            dir = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: refs.path, isDirectory: &dir))
            XCTAssertTrue(dir.boolValue)
            
            dir = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: objects.path, isDirectory: &dir))
            XCTAssertTrue(dir.boolValue)
            
            XCTAssertTrue($0.branch is MasterBranch)
            
            expect.fulfill()
        }.store(in: &subs)
        
        waitForExpectations(timeout: 1)
    }
}
