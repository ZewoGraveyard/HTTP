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

extension Request {
    public typealias Upgrade = (Response, Stream) throws -> Void

    public var upgrade: Upgrade? {
        get {
            return storage["request-upgrade"] as? Upgrade
        }

        set(upgrade) {
            storage["request-upgrade"] = upgrade
        }
    }
}

extension Request {
    public init(method: Method = .get, uri: URI = URI(path: "/"), headers: Headers = [:], body: Stream, upgrade: Upgrade?) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body
        )

        self.upgrade = upgrade
    }

    public init(method: Method = .get, uri: URI = URI(path: "/"), headers: Headers = [:], body: Data = Data(), upgrade: Upgrade?) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body
        )

        self.upgrade = upgrade
    }

    public init(method: Method = .get, uri: URI = URI(path: "/"), headers: Headers = [:], body: DataConvertible, upgrade: Upgrade? = nil) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body.data,
            upgrade: upgrade
        )
    }

    public init(method: Method = .get, uri: String, headers: Headers = [:], body: Data = Data(), upgrade: Upgrade? = nil) throws {
        self.init(
            method: method,
            uri: try URI(uri),
            headers: headers,
            body: body,
            upgrade: upgrade
        )
    }

    public init(method: Method = .get, uri: String, headers: Headers = [:], body: DataConvertible, upgrade: Upgrade? = nil) throws {
        try self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body.data,
            upgrade: upgrade
        )
    }

    public init(method: Method = .get, uri: String, headers: Headers = [:], body: Stream, upgrade: Upgrade? = nil) throws {
        self.init(
            method: method,
            uri: try URI(uri),
            headers: headers,
            body: body,
            upgrade: upgrade
        )
    }
}

extension Request {
    public var path: String? {
        return uri.path
    }

    public var query: Query {
        return uri.query
    }
}

extension Request {
    public var accept: [MediaType] {
        get {
            var acceptedMediaTypes: [MediaType] = []

            if let acceptString = headers["Accept"].merged() {
                let acceptedTypesString = acceptString.split(",")

                for acceptedTypeString in acceptedTypesString {
                    let acceptedTypeTokens = acceptedTypeString.split(";")

                    if acceptedTypeTokens.count >= 1 {
                        let mediaTypeString = acceptedTypeTokens[0].trim()
                        if let acceptedMediaType = try? MediaType(string: mediaTypeString) {
                            acceptedMediaTypes.append(acceptedMediaType)
                        }
                    }
                }
            }

            return acceptedMediaTypes
        }

        set(accept) {
            headers["Accept"] = Header(merging: accept.map({"\($0.type)/\($0.subtype)"}))
        }
    }

    public var cookies: Set<Cookie> {
        get {
            return headers["Cookie"].merged().flatMap(Cookie.parse) ?? []
        }

        set(cookies) {
            headers["Cookie"] = Header(merging: cookies.map({$0.description}))
        }
    }

    public var host: String? {
        get {
            return headers["Host"].first
        }

        set(host) {
            headers["Host"] = host.map({Header($0)}) ?? []
        }
    }

    public var userAgent: String? {
        get {
            return headers["User-Agent"].first
        }

        set(userAgent) {
            headers["User-Agent"] = Header(userAgent)
        }
    }

    public var authorization: String? {
        get {
            return headers["Authorization"].first
        }

        set(authorization) {
            headers["Authorization"] = Header(authorization)
        }
    }
}

extension Request {
    public var pathParameters: [String: String] {
        get {
            return storage["pathParameters"] as? [String: String] ?? [:]
        }

        set(pathParameters) {
            storage["pathParameters"] = pathParameters
        }
    }

    public var id: String? {
        get {
            return pathParameters["id"]
        }

        set(id) {
            pathParameters["id"] = id
        }
    }
}

extension Request: CustomStringConvertible {
    public var requestLineDescription: String {
        return "\(method) \(uri) HTTP/\(version.major).\(version.minor)\n"
    }

    public var description: String {
        return requestLineDescription +
            headers.description
    }
}

extension Request: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description + "\n\n" + storageDescription
    }
}