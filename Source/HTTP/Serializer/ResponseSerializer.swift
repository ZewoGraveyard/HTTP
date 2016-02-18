// ResponseSerializer.swift
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

public struct ResponseSerializer: ResponseSerializerType {
    public init() {}

    public func serialize(response: Response, @noescape send: Data throws -> Void) throws {
        let newLine: Data = [13, 10]

        try send("HTTP/\(response.version.major).\(response.version.minor) \(response.statusCode) \(response.reasonPhrase)".data)
        try send(newLine)

        for (name, value) in response.headers {
            try send("\(name): \(value)".data)
            try send(newLine)
        }

        for cookie in response.cookies {
            try send("Set-Cookie: \(cookie.description)".data)
            try send(newLine)
        }

        try send(newLine)

        switch response.body {
        case .Buffer(let data):
            try send(data)
        case .Stream(let bodyStream):
            while !bodyStream.closed {
                let data = try bodyStream.receive()
                try send(String(data.count, radix: 16).data)
                try send(newLine)
                try send(data)
                try send(newLine)
            }

            try send("0".data)
            try send(newLine)
            try send(newLine)
        }
    }
}
