// RequestSerializer.swift
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

public struct RequestSerializer: RequestSerializerType {
    public init() {}

    public func serialize(request: Request, @noescape send: Data throws -> Void) throws {
        try send("\(request.method) \(request.uri) HTTP/\(request.version.major).\(request.version.minor)\r\n".data)

        for (name, value) in request.headers {
            try send("\(name): \(value)\r\n".data)
        }

        try send("\r\n".data)

        switch request.body {
        case .Buffer(let data):
            try send(data)
        case .Stream(let bodyStream):
            while !bodyStream.closed {
                let data = try bodyStream.receive()
                try send("\(String(data.count, radix: 16))\r\n".data)
                try send(data)
                try send("\r\n".data)
            }

            try send("0\r\n".data)
            try send("\r\n".data)
        }
    }
}
