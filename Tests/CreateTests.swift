import XCTest
import Git

final class CreateTests: Tests {
    func testCreate() {
        var repository: Repository!
        let expect = expectation(description: "")
        
        let root = url.appendingPathComponent(".git")
        let refs = root.appendingPathComponent("refs")
        let objects = root.appendingPathComponent("objects")
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.path))
        
        git.create(url).sink {
            repository = $0
            XCTAssertEqual(.main, Thread.current)
            XCTAssertEqual(self.url, repository.url)
            
            var dir = ObjCBool(false)
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.path, isDirectory: &dir))
            XCTAssertTrue(dir.boolValue)
            
            dir = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: refs.path, isDirectory: &dir))
            XCTAssertTrue(dir.boolValue)
            
            dir = false
            XCTAssertTrue(FileManager.default.fileExists(atPath: objects.path, isDirectory: &dir))
            XCTAssertTrue(dir.boolValue)
            
            repository.branch.sink {
                XCTAssertEqual("master", $0)
                expect.fulfill()
            }.store(in: &self.subs)
        }.store(in: &subs)
        
        waitForExpectations(timeout: 1)
    }
}
