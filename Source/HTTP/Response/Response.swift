// Response.swift
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

@_exported import Stream

public struct Response: MessageType {
    public typealias Upgrade = (Request, StreamType) throws -> Void

    public var status: Status
    public var version: Version
    public var headers: Headers
    public var cookies: Cookies
    public var body: Body
    public var upgrade: Upgrade?

    public var storage: Storage = [:]

    init(status: Status, version: Version, headers: Headers, cookies: Cookies, body: Body, upgrade: Upgrade?) {
        self.status = status
        self.version = version
        self.headers = headers
        self.cookies = cookies
        self.body = body
        self.upgrade = upgrade
    }
}

extension Response {
    public init(status: Status = .OK, headers: Headers = [:], cookies: Cookies = [], body: Body, upgrade: Upgrade? = nil) {
        self.init(
            status: status,
            version: (major: 1, minor: 1),
            headers: headers,
            cookies: cookies,
            body: body,
            upgrade: upgrade
        )

        if let buffer = body.buffer  {
            contentLength = buffer.count
        } else {
            transferEncoding = "chunked"
        }
    }

    public init(status: Status = .OK, headers: Headers = [:], cookies: Cookies = [], body: Data = nil, upgrade: Upgrade? = nil) {
        self.init(
            status: status,
            headers: headers,
            cookies: cookies,
            body: .Buffer(body),
            upgrade: upgrade
        )
    }

    public init(status: Status = .OK, headers: Headers = [:], cookies: Cookies = [], body: DataConvertible, upgrade: Upgrade? = nil) {
        self.init(
            status: status,
            headers: headers,
            cookies: cookies,
            body: body.data,
            upgrade: upgrade
        )
    }

    public init(status: Status = .OK, headers: Headers = [:], cookies: Cookies = [], body: StreamType, upgrade: Upgrade? = nil) {
        self.init(
            status: status,
            headers: headers,
            cookies: cookies,
            body: .Stream(body),
            upgrade: upgrade
        )
    }

    public var statusCode: Int {
        return status.statusCode
    }

    public var reasonPhrase: String {
        return status.reasonPhrase
    }
}

extension Response: CustomStringConvertible {
    public var statusLineDescription: String {
        return "HTTP/1.1 " + statusCode.description + " " + reasonPhrase + "\n"
    }

    public var cookiesDescription: String {
        var string = ""

        for cookie in cookies {
            string += "Set-Cookie: \(cookie.description)\n"
        }

        return string
    }

    public var description: String {
        return statusLineDescription +
            headerDescription +
            cookiesDescription + "\n" +
            bodyDescription
    }
}

extension Response: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description + "\n\n" + storageDescription
    }
}

extension Response: Hashable {
    public var hashValue: Int {
        return description.hashValue
    }
}

public func ==(lhs: Response, rhs: Response) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
