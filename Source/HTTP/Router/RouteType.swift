// RouteType.swift
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

public struct Action: ResponderType {
    public let middleware: [MiddlewareType]
    public let responder: ResponderType

    public init(middleware: [MiddlewareType], responder: ResponderType) {
        self.middleware = middleware
        self.responder = responder
    }

    public init(_ responder: ResponderType) {
        self.init(
            middleware: [],
            responder: responder
        )
    }

    public init(middleware: [MiddlewareType], respond: Respond) {
        self.init(
            middleware: middleware,
            responder: Responder(respond)
        )
    }

    public init(_ respond: Respond) {
        self.init(
            middleware: [],
            responder: Responder(respond)
        )
    }

    public func respond(request: Request) throws -> Response {
        return try middleware.intercept(responder).respond(request)
    }
}

public protocol RouteType: ResponderType, CustomStringConvertible {
    var path: String { get }
    var actions: [Method: Action] { get }
    var fallback: Action { get }
}

extension RouteType {
    public var fallback: Action {
        return Action { _ in
            Response(status: .MethodNotAllowed)
        }
    }

    public func respond(request: Request) throws -> Response {
        let action = actions[request.method] ?? fallback
        return try action.respond(request)
    }
}

extension RouteType {
    public var description: String {
        var string = ""
        for (method, action) in actions {
            string += "\(method) \(path) \(action.middleware) \(action.responder)\n"
        }
        string += "\(fallback)"
        return string
    }
}

public final class Route: RouteType {
    public let path: String
    public var actions: [Method: Action]
    public var fallback: Action

    public init(path: String, actions: [Method: Action] = [:], fallback: Action = Route.defaultFallback) {
        self.path = path
        self.actions = actions
        self.fallback = fallback
    }

    public func addAction(method method: Method, action: Action) {
        actions[method] = action
    }

    public static let defaultFallback = Action { _ in
        Response(status: .MethodNotAllowed)
    }
}
