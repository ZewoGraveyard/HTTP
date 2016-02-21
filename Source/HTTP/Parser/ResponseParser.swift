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
@_exported import Data

typealias ResponseContext = UnsafeMutablePointer<ResponseParserContext>

struct ResponseParserContext {
    var statusCode: Int = 0
    var reasonPhrase: String = ""
    var version: (major: Int, minor: Int) = (0, 0)
    var headers: Headers = [:]
    var cookies: Cookies = []
    var body: Data = []

    var buildingCookieValue = ""
    var buildingHeaderField = ""
    var currentHeaderField = ""
    var completion: Response -> Void

    init(completion: Response -> Void) {
        self.completion = completion
    }
}

var responseSettings: http_parser_settings = {
    var settings = http_parser_settings()
    http_parser_settings_init(&settings)

    settings.on_status           = onResponseStatus
    settings.on_header_field     = onResponseHeaderField
    settings.on_header_value     = onResponseHeaderValue
    settings.on_headers_complete = onResponseHeadersComplete
    settings.on_body             = onResponseBody
    settings.on_message_complete = onResponseMessageComplete

    return settings
}()

public final class ResponseParser: ResponseParserType {
    let context: ResponseContext
    var parser = http_parser()
    var response: Response?

    public init() {
        context = ResponseContext.alloc(1)
        context.initialize(ResponseParserContext { response in
            self.response = response
        })

        resetParser()
    }

    deinit {
        context.destroy()
        context.dealloc(1)
    }

    func resetParser() {
        http_parser_init(&parser, HTTP_RESPONSE)
        parser.data = UnsafeMutablePointer<Void>(context)
    }

    public func parse(data: Data) throws -> Response? {
        defer { response = nil }

        var data = data

        let buffer = data.withUnsafeMutableBufferPointer {
            UnsafeMutablePointer<Int8>($0.baseAddress)
        }

        let bytesParsed = http_parser_execute(&parser, &responseSettings, buffer, data.count)

        if bytesParsed != data.count {
            resetParser()
            let errorName = http_errno_name(http_errno(parser.http_errno))
            let errorDescription = http_errno_description(http_errno(parser.http_errno))
            let error = ParseError(description: "\(String.fromCString(errorName)!): \(String.fromCString(errorDescription)!)")
            throw error
        }

        if response != nil {
            resetParser()
        }

        return response
    }
}

extension ResponseParser {
    public func parse(convertible: DataConvertible) throws -> Response? {
        return try parse(convertible.data)
    }
}

func onResponseStatus(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    return ResponseContext(parser.memory.data).withMemory {
        guard let reasonPhrase = String(pointer: data, length: length) else {
            return 1
        }

        $0.reasonPhrase += reasonPhrase
        return 0
    }
}

func onResponseHeaderField(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    return ResponseContext(parser.memory.data).withMemory {
        guard let headerField = String(pointer: data, length: length) else {
            return 1
        }

        if $0.buildingCookieValue != "" {
            if let cookie = try? Cookie.parseSetCookie($0.buildingCookieValue) {
                $0.cookies.insert(cookie)
            }
            $0.buildingCookieValue = ""
        }

        $0.buildingHeaderField += headerField
        return 0
    }
}

func onResponseHeaderValue(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    return ResponseContext(parser.memory.data).withMemory {
        if $0.buildingHeaderField != "" {
            $0.currentHeaderField = $0.buildingHeaderField
        }

        $0.buildingHeaderField = ""
        let headerField = $0.currentHeaderField

        guard let headerValue = String(pointer: data, length: length) else {
            return 1
        }

        if headerField == "Set-Cookie" {
            $0.buildingCookieValue += headerValue
        } else {
            let previousHeaderValue = $0.headers[HeaderName(name: headerField)] ?? ""
            $0.headers[HeaderName(name: headerField)] = previousHeaderValue + headerValue
        }

        return 0
    }
}

func onResponseHeadersComplete(parser: Parser) -> Int32 {
    return ResponseContext(parser.memory.data).withMemory {
        if $0.buildingCookieValue != "" {
            if let cookie = try? Cookie.parseSetCookie($0.buildingCookieValue) {
                $0.cookies.insert(cookie)
            }
        }

        $0.buildingCookieValue = ""
        $0.buildingHeaderField = ""
        $0.currentHeaderField = ""
        $0.statusCode = Int(parser.memory.status_code)
        $0.version = (Int(parser.memory.http_major), Int(parser.memory.http_minor))
        return 0
    }
}

func onResponseBody(parser: Parser, data: UnsafePointer<Int8>, length: Int) -> Int32 {
    return ResponseContext(parser.memory.data).withMemory {
        $0.body += Data(pointer: data, length: length)
        return 0
    }
}

func onResponseMessageComplete(parser: Parser) -> Int32 {
    return ResponseContext(parser.memory.data).withMemory {
        let response = Response(
            status: Status(statusCode: $0.statusCode, reasonPhrase: $0.reasonPhrase),
            version: $0.version,
            headers: $0.headers,
            cookies: $0.cookies,
            body: .Buffer($0.body),
            upgrade: nil
        )

        $0.completion(response)

        $0.statusCode = 0
        $0.reasonPhrase = ""
        $0.version = (0, 0)
        $0.headers = [:]
        $0.cookies = []
        $0.body = []
        return 0
    }
}
