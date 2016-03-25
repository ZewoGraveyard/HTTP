// MessageTests.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@testable import HTTP
import XCTest

#if os(Linux)
extension MessageTests: XCTestCaseProvider {
    var allTests: [(String, () throws -> Void)] {
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
#endif

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
        XCTAssertEqual(request.headers["Cookie"][0], "server=zewo, lang=swift")
    }

    func testMultipleCookiesResponse() {
        var response = Response()
        response.cookies.insert(AttributedCookie(name: "server", value: "zewo"))
        response.cookies.insert(AttributedCookie(name: "lang", value: "swift"))
        XCTAssertEqual(response.headers["Set-Cookie"][0], "server=zewo")
        XCTAssertEqual(response.headers["Set-Cookie"][1], "lang=swift")
    }
}