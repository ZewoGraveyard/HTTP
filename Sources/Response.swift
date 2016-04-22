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

extension Response {
    public typealias OnUpgrade = (Request, Stream) throws -> Void

    public var onUpgrade: OnUpgrade? {
        get {
            return storage["response-connection-upgrade"] as? OnUpgrade
        }

        set(onUpgrade) {
            storage["response-connection-upgrade"] = onUpgrade
        }
    }
}

extension Response {
    public init(status: Status = .ok, headers: Headers = [:], body: Stream, onUpgrade: OnUpgrade?) {
        self.init(
            status: status,
            headers: headers,
            body: body
        )

        self.onUpgrade = onUpgrade
    }

    public init(status: Status = .ok, headers: Headers = [:], body: Data = Data(), onUpgrade: OnUpgrade?) {
        self.init(
            status: status,
            headers: headers,
            body: body
        )

        self.onUpgrade = onUpgrade
    }

    public init(status: Status = .ok, headers: Headers = [:], body: DataConvertible, onUpgrade: OnUpgrade? = nil) {
        self.init(
            status: status,
            headers: headers,
            body: body.data,
            onUpgrade: onUpgrade
        )
    }
}

extension Response {
    public var statusCode: Int {
        return status.statusCode
    }

    public var reasonPhrase: String {
        return status.reasonPhrase
    }
}

extension Response {
    public var cookies: Set<AttributedCookie> {
        get {
            return headers["Set-Cookie"].reduce(Set<AttributedCookie>()) { cookies, header in
                AttributedCookie.parse(header).map({cookies.union([$0])}) ?? cookies
            }
        }

        set(cookies) {
            headers["Set-Cookie"] = Header(cookies.map({$0.description}))
        }
    }
}

extension Response: CustomStringConvertible {
    public var statusLineDescription: String {
        return "HTTP/1.1 " + statusCode.description + " " + reasonPhrase + "\n"
    }

    public var description: String {
        return statusLineDescription +
            headers.description
    }
}

extension Response: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description + "\n\n" + storageDescription
    }
}
