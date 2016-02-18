// ParserTests.swift
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

import XCTest
import HTTP

class ParserTests: XCTestCase {
    func testRequestParserCookie() {
        let parser = RequestParser()
        var request: Request?

        request = try! parser.parse("GET / HTTP/1.1\r\nCookie: theme=l")
        XCTAssert(request == nil)
        request = try! parser.parse("ight; s")
        XCTAssert(request == nil)
        request = try! parser.parse("essionToken=")
        XCTAssert(request == nil)
        request = try! parser.parse("abc123\r\n\r\n")
        XCTAssert(request != nil)
        XCTAssert(request?.cookies.count == 2)
        XCTAssert(request?.cookies[0].name == "theme")
        XCTAssert(request?.cookies[0].value == "light")
        XCTAssert(request?.cookies[1].name == "sessionToken")
        XCTAssert(request?.cookies[1].value == "abc123")
    }

    func testResponseParserCookie() {
        let parser = ResponseParser()
        var response: Response?

        response = try! parser.parse("HTTP/1.0 200 OK\r\nSet-Cookie: LSID=DQAAAEa")
        XCTAssert(response == nil)
        response = try! parser.parse("em_vYg; Path=/accounts; Expires=")
        XCTAssert(response == nil)
        response = try! parser.parse("Wed, 13 Jan 2021 22:23:01 GMT; Secure; HttpOnly\r")
        XCTAssert(response == nil)
        response = try! parser.parse("\nSet-Cookie: made_wri")
        XCTAssert(response == nil)
        response = try! parser.parse("te_conn=1295214458; Path=/; Domain=.example.com")
        XCTAssert(response == nil)
        response = try! parser.parse("\r\nContent-Length: 0\r\n\r\n")
        XCTAssert(response != nil)
        XCTAssert(response?.cookies.count == 2)
        XCTAssert(response?.cookies[0].name == "LSID")
        XCTAssert(response?.cookies[0].value == "DQAAAEaem_vYg")
        XCTAssert(response?.cookies[0].attributes["Path"] == "/accounts")
        XCTAssert(response?.cookies[0].attributes["Expires"] == "Wed, 13 Jan 2021 22:23:01 GMT")
        XCTAssert(response?.cookies[0].attributes["Secure"] == "")
        XCTAssert(response?.cookies[0].attributes["HttpOnly"] == "")
        XCTAssert(response?.cookies[1].name == "made_write_conn")
        XCTAssert(response?.cookies[1].value == "1295214458")
        XCTAssert(response?.cookies[1].attributes["Path"] == "/")
        XCTAssert(response?.cookies[1].attributes["Domain"] == ".example.com")
    }
}
