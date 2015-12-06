// HTTPRequest.swift
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

import URI

public struct HTTPRequest {
    public let method: HTTPMethod
    public let uri: URI
    public let majorVersion: Int
    public let minorVersion: Int
    public let headers: [String: String]
    public let body: [Int8]

    public var parameters: [String: String] = [:]
    public var context: [String: Any] = [:]

    public init(method: HTTPMethod, uri: URI, majorVersion: Int, minorVersion: Int, headers: [String: String], body: [Int8]) {
        self.method = method
        self.uri = uri
        self.majorVersion = majorVersion
        self.minorVersion = minorVersion
        self.headers = headers
        self.body = body
    }
}

extension HTTPRequest {
    public init(method: HTTPMethod, uri: URI, headers: [String: String] = [:], body: [Int8] = []) {
        self.method = method
        self.uri = uri
        self.majorVersion = 1
        self.minorVersion = 1
        var headers = headers
        headers["Content-Length"] = "\(body.count)"
        self.headers = headers
        self.body = body
    }

    public init(method: HTTPMethod, uri: URI, headers: [String: String] = [:], body: String) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body.data
        )
    }

    public func getHeader(header: String) -> String? {
        for (key, value) in headers where key.lowercaseString == header.lowercaseString {
            return value
        }
        return nil
    }

    public var keepAlive: Bool {
        if minorVersion == 0 {
            return getHeader("connection")?.lowercaseString == "keep-alive"
        } else {
            return getHeader("connection")?.lowercaseString != "close"
        }
    }

    public var upgrade: Bool {
        return getHeader("connection")?.lowercaseString == "upgrade"
    }

    public var contentType: MediaType? {
        if let contentType = getHeader("content-type") {
            return MediaType(string: contentType)
        }
        return nil
    }

    public var bodyString: String? {
        return String(data: body)
    }

    public var bodyHexString: String {
        return body.hexString
    }
}

extension HTTPRequest: CustomStringConvertible {
    public var description: String {
        var string = "\(method) \(uri) HTTP/\(majorVersion).\(minorVersion)\n"

        for (header, value) in headers {
            string += "\(header): \(value)\n"
        }

        if body.count > 0 {
            if let bodyString = bodyString {
                string += "\n" + bodyString
            } else  {
                string += "\n" + bodyHexString
            }
        }
        
        return string
    }
}

extension HTTPRequest: Hashable {
    public var hashValue: Int {
        return description.hashValue
    }
}

public func ==(lhs: HTTPRequest, rhs: HTTPRequest) -> Bool {
    return lhs.hashValue == rhs.hashValue
}