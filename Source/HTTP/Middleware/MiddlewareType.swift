// MiddlewareType.swift
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

public protocol MiddlewareType {
    func respond(request: Request, chain: ChainType) throws -> Response
}

extension MiddlewareType {
    public func intercept(responder: ResponderType) -> ResponderType {
        return Responder { request in
            return try self.respond(request, chain: responder)
        }
    }

    public func intercept(chain: ChainType) -> ChainType {
        return Responder { request in
            return try self.respond(request, chain: chain)
        }
    }
}

public struct Middleware: MiddlewareType {
    let respond: (request: Request, chain: ChainType) throws -> Response

    public init(respond: (request: Request, chain: ChainType) throws -> Response) {
        self.respond = respond
    }

    public func respond(request: Request, chain: ChainType) throws -> Response {
        return try respond(request: request, chain: chain)
    }
}

extension CollectionType where Self.Generator.Element == MiddlewareType {
    public func intercept(responder: ChainType) -> ChainType {
        var responder = responder

        for middleware in self.reverse() {
            responder = middleware.intercept(responder)
        }

        return responder
    }

    public func intercept(responder: ResponderType) -> ResponderType {
        var responder = responder

        for middleware in self.reverse() {
            responder = middleware.intercept(responder)
        }

        return responder
    }

    public func intercept(respond: Respond) -> ResponderType {
        return intercept(Responder(respond: respond))
    }
}

public func chain(middleware middleware: MiddlewareType..., responder: ResponderType) -> ResponderType {
    return middleware.intercept(responder)
}

public func chain(middleware middleware: MiddlewareType..., respond: Respond) -> ResponderType {
    return middleware.intercept(respond)
}