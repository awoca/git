import XCTest
@testable import Git

final class IdTests: Tests {
    func testHead() {
        let id = Id("95d09f2b10159347eece71399a7e2e907ea3df4f")
        XCTAssertEqual("95", id.head)
        XCTAssertEqual("d09f2b10159347eece71399a7e2e907ea3df4f", id.tail)
    }
}
