// MessageType.swift
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
@_exported import MediaType

public typealias Headers = [Header: String]

public struct Header {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

extension Header: Hashable {
    public var hashValue: Int {
        return name.lowercaseString.hashValue
    }
}

public func ==(lhs: Header, rhs: Header) -> Bool {
    return lhs.name.lowercaseString == rhs.name.lowercaseString
}

extension Header: StringLiteralConvertible {
    public init(stringLiteral string: String) {
        self.init(name: string)
    }

    public init(extendedGraphemeClusterLiteral string: String){
        self.init(name: string)
    }

    public init(unicodeScalarLiteral string: String){
        self.init(name: string)
    }
}

extension Header: CustomStringConvertible {
    public var description: String {
        return name
    }
}

public typealias Cookies = [Cookie]

public enum Body {
    case Buffer(Data)
    case Stream(StreamType)
}

extension Body {
    public var buffer: Data? {
        switch self {
        case .Buffer(let data): return data
        default: return nil
        }
    }

    public var stream: StreamType? {
        switch self {
        case .Stream(let stream): return stream
        default: return nil
        }
    }

    public var isBuffer: Bool {
        switch self {
        case .Buffer: return true
        default: return false
        }
    }

    public var isStream: Bool {
        switch self {
        case .Stream: return true
        default: return false
        }
    }
}

public protocol MessageType {
    var version: (major: Int, minor: Int) { get set }
    var headers: Headers { get set }
    var cookies: Cookies { get set }
    var body: Body { get set }
    var storage: [String: Any] { get set }
}

extension MessageType {
    public var contentType: MediaType? {
        get {
            if let contentType = headers["content-type"] {
                return MediaType(string: contentType)
            }
            return nil
        }

        set {
            headers["Content-Type"] = newValue?.description
        }
    }

    public var contentLength: Int? {
        get {
            if let contentLength = headers["Content-Length"] {
                return Int(contentLength)
            }

            return nil
        }

        set {
            headers["Content-Length"] = newValue?.description
        }
    }

    public var isChunkEncoded: Bool {
        return transferEncoding?.lowercaseString == "chunked"
    }

    public var transferEncoding: String? {
        get {
            return headers["Transfer-Encoding"]
        }

        set {
            headers["Transfer-Encoding"] = newValue
        }
    }

    public var connection: String? {
        get {
            return headers["Connection"]
        }

        set {
            headers["Connection"] = newValue
        }
    }

    public var isKeepAlive: Bool {
        if version.minor == 0 {
            return connection?.lowercaseString == "keep-alive"
        }

        return connection?.lowercaseString != "close"
    }

    public var isUpgrade: Bool {
        return connection?.lowercaseString == "upgrade"
    }

    public var upgrade: String? {
        get {
            return headers["Upgrade"]
        }

        set {
            headers["Upgrade"] = newValue
        }
    }

    public var headerDescription: String {
        var string = ""

        for (header, value) in headers {
            string += "\(header): \(value)\n"
        }

        return string
    }

    public var bodyDescription: String {
        switch body {
        case .Buffer(let data):
            if data.count == 0 {
                return "-"
            }

            return data.description
        case .Stream:
            return "Stream"
        }
    }

    public var storageDescription: String {
        var string = "Storage:\n"

        if storage.count == 0 {
            string += "-"
        }

        for (index, (key, value)) in storage.enumerate() {
            string += "\(key): \(value)"

            if index < storage.count - 1 {
                string += "\n"
            }
        }

        return string
    }

    public var bodyString: String? {
        switch body {
        case .Buffer(let data):
            return try? String(data: data)
        case .Stream:
            return nil
        }
    }
}