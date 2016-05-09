@testable import HTTP
import XCTest

class MessageTests: XCTestCase {
    func testHeaderCaseInsensitivity() {
        var request = Request()
        request.headers["Content-Type"] = "application/json"
        XCTAssertEqual(request.headers["content-TYPE"], "application/json")
    }

    func testAppendHeaderValue() {
        var request = Request()
        request.headers["X-Header"] = "First Value"
        request.headers["X-Header"].append("Second Value")
        request.headers["Y-Header"] = "Third Value"
        XCTAssertEqual(request.headers.count, 3) // We have implicit Content-Length

        if request.headers["x-header"].count == 2 {
            XCTAssertEqual(request.headers["x-header"][0], "First Value")
            XCTAssertEqual(request.headers["x-header"][1], "Second Value")
        } else {
            XCTAssertEqual(request.headers["x-header"].count, 2)
        }

        XCTAssertEqual(request.headers["y-Header"].count, 1)

        if request.headers["Y-header"].count == 1 {
            XCTAssertEqual(request.headers["Y-Header"][0], "Third Value")
        } else {
            XCTAssertEqual(request.headers["Y-Header"].count, 1)
        }
    }

    func testContentType() {
        let request = Request(headers: ["Content-Type": ["application/json"]])
        XCTAssertEqual(request.contentType, MediaType(type: "application", subtype: "json"))
    }

    func testDuplicateContentType() {
        let request = Request(headers: ["Content-Type": ["application/json", "application/xml"]])
        XCTAssertEqual(request.contentType, MediaType(type: "application", subtype: "json"))
    }

    func testOneCookieRequest() {
        var request = Request()
        request.cookies.insert(Cookie(name: "server", value: "zewo"))
        XCTAssertEqual(request.headers["Cookie"][0], "server=zewo")
    }

    func testMultipleCookiesRequest() {
        var request = Request()
        request.cookies.insert(Cookie(name: "server", value: "zewo"))
        request.cookies.insert(Cookie(name: "lang", value: "swift"))
        XCTAssert(
            request.headers["Cookie"][0] ==  "server=zewo, lang=swift" ||
            request.headers["Cookie"][0] ==  "lang=swift, server=zewo"
        )
    }

    func testMultipleCookiesResponse() {
        var response = Response()
        response.cookies.insert(AttributedCookie(name: "server", value: "zewo"))
        response.cookies.insert(AttributedCookie(name: "lang", value: "swift"))
        let cookie0 = response.headers["Set-Cookie"][0]
        let cookie1 = response.headers["Set-Cookie"][1]
        XCTAssert(
            ( cookie0 ==  "lang=swift" &&
            cookie1 ==  "server=zewo") ||
            (cookie0 ==  "server=zewo" &&
            cookie1 ==  "lang=swift")
        )
    }
}

extension MessageTests {
    static var allTests: [(String, MessageTests -> () throws -> Void)] {
        return [
            ("testHeaderCaseInsensitivity", testHeaderCaseInsensitivity),
            ("testAppendHeaderValue", testAppendHeaderValue),
            ("testContentType", testContentType),
            ("testDuplicateContentType", testDuplicateContentType),
            ("testOneCookieRequest", testOneCookieRequest),
            ("testMultipleCookiesRequest", testMultipleCookiesRequest),
            ("testMultipleCookiesResponse", testMultipleCookiesResponse),
        ]
    }
}
