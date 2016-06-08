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
    public typealias DidUpgrade = (Response, Stream) throws -> Void

    public var didUpgrade: DidUpgrade? {
        get {
            return storage["request-connection-upgrade"] as? DidUpgrade
        }

        set(didUpgrade) {
            storage["request-connection-upgrade"] = didUpgrade
        }
    }
}

extension Request {
    public init(method: Method = .get, uri: URI = URI(path: "/"), headers: Headers = [:], body: Stream, didUpgrade: DidUpgrade?) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body
        )

        self.didUpgrade = didUpgrade
    }

    public init(method: Method = .get, uri: URI = URI(path: "/"), headers: Headers = [:], body: Data = Data(), didUpgrade: DidUpgrade?) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body
        )

        self.didUpgrade = didUpgrade
    }

    public init(method: Method = .get, uri: URI = URI(path: "/"), headers: Headers = [:], body: DataConvertible, didUpgrade: DidUpgrade? = nil) {
        self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body.data,
            didUpgrade: didUpgrade
        )
    }

    public init(method: Method = .get, uri: String, headers: Headers = [:], body: Data = Data(), didUpgrade: DidUpgrade? = nil) throws {
        self.init(
            method: method,
            uri: try URI(uri),
            headers: headers,
            body: body,
            didUpgrade: didUpgrade
        )
    }

    public init(method: Method = .get, uri: String, headers: Headers = [:], body: DataConvertible, didUpgrade: DidUpgrade? = nil) throws {
        try self.init(
            method: method,
            uri: uri,
            headers: headers,
            body: body.data,
            didUpgrade: didUpgrade
        )
    }

    public init(method: Method = .get, uri: String, headers: Headers = [:], body: Stream, didUpgrade: DidUpgrade? = nil) throws {
        self.init(
            method: method,
            uri: try URI(uri),
            headers: headers,
            body: body,
            didUpgrade: didUpgrade
        )
    }
}

extension Request {
    public var path: String? {
        return uri.path
    }

    public var query: [String: [String?]] {
        return uri.query
    }
}

extension Request {
    public var accept: [MediaType] {
        get {
            var acceptedMediaTypes: [MediaType] = []

            if let acceptString = headers["Accept"] {
                let acceptedTypesString = acceptString.split(separator: ",")

                for acceptedTypeString in acceptedTypesString {
                    let acceptedTypeTokens = acceptedTypeString.split(separator: ";")

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
            headers["Accept"] = accept.map({"\($0.type)/\($0.subtype)"}).joined(separator: ", ")
        }
    }

    // Waiting on removal of cookies at S4

    // public var cookies: Set<Cookie> {
    //     get {
    //         return headers["Cookie"].merged().flatMap(Cookie.parse) ?? []
    //     }

    //     set(cookies) {
    //         headers["Cookie"] = Header(merging: cookies.map({$0.description}))
    //     }
    // }

    public var host: String? {
        get {
            return headers["Host"]
        }

        set(host) {
            headers["Host"] = host
        }
    }

    public var userAgent: String? {
        get {
            return headers["User-Agent"]
        }

        set(userAgent) {
            headers["User-Agent"] = userAgent
        }
    }

    public var authorization: String? {
        get {
            return headers["Authorization"]
        }

        set(authorization) {
            headers["Authorization"] = authorization
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
