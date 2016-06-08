@testable import HTTP
import XCTest

class MessageTests: XCTestCase {
    func testHeaderCaseInsensitivity() {
        var request = Request()
        request.headers["Content-Type"] = "application/json"
        XCTAssertEqual(request.headers["content-TYPE"], "application/json")
    }

    func testContentType() {
        let request = Request(headers: ["Content-Type": "application/json"])
        XCTAssertEqual(request.contentType, MediaType(type: "application", subtype: "json"))
    }
}

extension MessageTests {
    static var allTests: [(String, (MessageTests) -> () throws -> Void)] {
        return [
            ("testHeaderCaseInsensitivity", testHeaderCaseInsensitivity),
            ("testContentType", testContentType),
        ]
    }
}
