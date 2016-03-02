// RequestParser.swift
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

import CHTTPParser
@_exported import URI
@_exported import Data
@_exported import String

typealias RequestContext = UnsafeMutablePointer<RequestParserContext>

struct RequestParserContext {
    var method: Method! = nil
    var uri: URI! = nil
    var version: (major: Int, minor: Int) = (0, 0)
    var headers: Headers = [:]
    var cookies: Cookies = []
    var body: Data = []

    var buildingCookieValue = ""
    var currentURI = ""
    var buildingHeaderField = ""
    var currentHeaderField = ""
    var completion: Request -> Void

    init(completion: Request -> Void) {
        self.completion = completion
    }
}

var requestSettings: http_parser_settings = {
    var settings = http_parser_settings()
    http_parser_settings_init(&settings)

    settings.on_url              = onRequestURL
    settings.on_header_field     = onRequestHeaderField
    settings.on_header_value     = onRequestHeaderValue
    settings.on_headers_complete = onRequestHeadersComplete
    settings.on_body             = onRequestBody
    settings.on_message_complete = onRequestMessageComplete

    return settings
}()

public final class RequestParser: RequestParserType {
    let context: RequestContext
    var parser = http_parser()
    var request: Request?

    public init() {
        context = RequestContext.alloc(1)
        context.initialize(RequestParserContext { request in
            self.request = request
        })

        resetParser()
    }

    deinit {
        context.destroy()
        context.dealloc(1)
    }

    func resetParser() {
        http_parser_init(&parser, HTTP_REQUEST)
        parser.data = UnsafeMutablePointer<Void>(context)
    }

    public func parse(data: Data) throws -> Request? {
        defer { request = nil }

        let buffer = data.withUnsafeBufferPointer {
            UnsafeMutablePointer<Int8>($0.baseAddress)
        }

        let bytesParsed = http_parser_execute(&parser, &requestSettings, buffer, data.count)

        if bytesParsed != data.count {
            resetParser()
            let errorName = http_errno_name(http_errno(parser.http_errno))
            let errorDescription = http_errno_description(http_errno(parser.http_errno))
            let error = ParseError(description: "\(String.fromCString(errorName)!): \(String.fromCString(errorDescription)!)")
            throw error
        }

        if request != nil {
            resetParser()
        }

        return request
    }
}

extension RequestParser {
    public func parse(convertible: DataConvertible) throws -> Request? {
        return try parse(convertible.data)
    }
}

func onRequestURL(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    return RequestContext(parser.memory.data).withMemory {
        guard let uri = String(pointer: data, length: length) else {
            return 1
        }

        $0.currentURI += uri
        return 0
    }
}

func onRequestHeaderField(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    return RequestContext(parser.memory.data).withMemory {
        guard let headerField = String(pointer: data, length: length) else {
            return 1
        }

        if $0.buildingCookieValue != "" {
            $0.buildingCookieValue = ""
        }

        $0.buildingHeaderField += headerField
        return 0
    }
}

func onRequestHeaderValue(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    return RequestContext(parser.memory.data).withMemory {
        if $0.buildingHeaderField != "" {
            $0.currentHeaderField = $0.buildingHeaderField
        }

        $0.buildingHeaderField = ""
        let headerField = $0.currentHeaderField

        guard let headerValue = String(pointer: data, length: length) else {
            return 1
        }

        if headerField == "Cookie" {
            $0.buildingCookieValue += headerValue
        } else {
            let headerName = HeaderName(headerField)
            let previousHeaderValue = $0.headers[headerName] ?? ""
            $0.headers[headerName] = previousHeaderValue + headerValue
        }

        return 0
    }
}

func onRequestHeadersComplete(parser: Parser) -> Int32 {
    return RequestContext(parser.memory.data).withMemory {
        $0.method = Method(code: Int(parser.memory.method))
        $0.version = (Int(parser.memory.http_major), Int(parser.memory.http_minor))

        guard let uri = try? URI($0.currentURI) else {
            return 1
        }

        if $0.buildingCookieValue != "" {
            if let cookies = try? Cookie.parseCookie($0.buildingCookieValue) {
                $0.cookies = cookies
            }
        }

        $0.buildingCookieValue = ""
        $0.uri = uri
        $0.currentURI = ""
        $0.buildingHeaderField = ""
        $0.currentHeaderField = ""
        return 0
    }
}

func onRequestBody(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    RequestContext(parser.memory.data).withMemory {
        $0.body += Data(pointer: data, length: length)
    }

    return 0
}

func onRequestMessageComplete(parser: Parser) -> Int32 {
    return RequestContext(parser.memory.data).withMemory {
        let request = Request(
            method: $0.method,
            uri: $0.uri,
            version: $0.version,
            headers: $0.headers,
            cookies: $0.cookies,
            body: .Buffer($0.body),
            upgrade: nil
        )

        $0.completion(request)

        $0.method = nil
        $0.uri = nil
        $0.version = (0, 0)
        $0.headers = [:]
        $0.cookies = []
        $0.body = []
        return 0
    }
}
