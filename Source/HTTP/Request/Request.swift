// Request.swift
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

@_exported import URI
@_exported import Stream
@_exported import String

public struct Request: MessageType {
    public typealias Upgrade = (Response, StreamType) throws -> Void

    public var method: Method
    public var uri: URI
    public var version: (major: Int, minor: Int)
    public var headers: Headers
    public var body: Body
    public var upgrade: Upgrade?

    public var storage: [String: Any] = [:]

    init(method: Method, uri: URI, version: (major: Int, minor: Int), headers: Headers, body: Body, upgrade: Upgrade?) {
        self.method = method
        self.uri = uri
        self.version = version
        self.headers = headers
        self.body = body
        self.upgrade = upgrade
    }
}

extension Request {
    public init(method: Method, uri: URI, headers: Headers = [:], body: Body, upgrade: Upgrade? = nil) {
        self.init(
            method: method,
            uri: uri,
            version: (major: 1, minor: 1),
            headers: headers,
            body: body,
            upgrade: upgrade
        )

        if let buffer = body.buffer  {
            contentLength = buffer.count
        } else {
            transferEncoding = "chunked"
        }
    }

    public init(method: Method, uri: URI, headers: Headers = [:], body: Data = nil, upgrade: Upgrade? = nil) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: .Buffer(body),
            upgrade: upgrade
        )
    }

    public init(method: Method, uri: URI, headers: Headers = [:], body: DataConvertible, upgrade: Upgrade? = nil) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body.data,
            upgrade: upgrade
        )
    }

    public init(method: Method, uri: URI, headers: Headers = [:], body: StreamType, upgrade: Upgrade? = nil) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: .Stream(body),
            upgrade: upgrade
        )
    }

    public init(method: Method, uri: String, headers: Headers = [:], body: Data = nil, upgrade: Upgrade? = nil) throws {
        self.init(
            method: method,
            uri: try URI(string: uri),
            headers: headers,
            body: body,
            upgrade: upgrade
        )
    }

    public init(method: Method, uri: String, headers: Headers = [:], body: DataConvertible, upgrade: Upgrade? = nil) throws {
        try self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body.data,
            upgrade: upgrade
        )
    }

    public init(method: Method, uri: String, headers: Headers = [:], body: StreamType, upgrade: Upgrade? = nil) throws {
        self.init(
            method: method,
            uri: try URI(string: uri),
            headers: headers,
            body: body,
            upgrade: upgrade
        )
    }

    public var accept: [MediaType] {
        get {
            var acceptedMediaTypes: [MediaType] = []

            if let acceptString = headers["Accept"] {
                let acceptedTypesString = acceptString.split(",")

                for acceptedTypeString in acceptedTypesString {
                    let acceptedTypeTokens = acceptedTypeString.split(";")

                    if acceptedTypeTokens.count >= 1 {
                        let mediaTypeString = acceptedTypeTokens[0].trim()
                        acceptedMediaTypes.append(MediaType(string: mediaTypeString))
                    }
                }
            }

            return acceptedMediaTypes
        }

        set {
            let header = newValue.map({"\($0.type)/\($0.subtype)"}).joinWithSeparator(", ")
            headers["Accept"] = header
        }
    }

    public var host: String? {
        get {
            return headers["Host"]
        }

        set {
            headers["Host"] = newValue
        }
    }

    public var userAgent: String? {
        get {
            return headers["User-Agent"]
        }

        set {
            headers["User-Agent"] = newValue
        }
    }

    public var authorization: String? {
        get {
            return headers["Authorization"]
        }

        set {
            headers["Authorization"] = newValue
        }
    }

    public var pathParameters: [String: String] {
        set {
            storage["pathParameters"] = newValue
        }
        get {
            return storage["pathParameters"] as? [String: String] ?? [:]
        }
    }

    public var path: String? {
        return uri.path
    }

    public var query: [String: String] {
        return uri.query
    }
}

extension Request: CustomStringConvertible {
    public var requestLineDescription: String {
        return "\(method) \(uri) HTTP/\(version.major).\(version.minor)"
    }

    public var description: String {
        return requestLineDescription + "\n" +
            headerDescription + "\n\n" +
            bodyDescription
    }
}

extension Request: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description + "\n\n" + storageDescription
    }
}

extension Request: Hashable {
    public var hashValue: Int {
        return description.hashValue
    }
}

public func ==(lhs: Request, rhs: Request) -> Bool {
    return lhs.hashValue == rhs.hashValue
}