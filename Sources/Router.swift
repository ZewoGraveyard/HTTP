// Router.swift
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

public protocol RouterRepresentable: ResponderRepresentable {
    var router: RouterProtocol { get }
}

extension RouterRepresentable {
    public var responder: Responder {
        return router
    }
}

public protocol RouterProtocol: Responder, RouterRepresentable {
    var routes: [Route] { get }
    var fallback: Responder { get }
    func match(_ request: Request) -> Route?
}

extension RouterProtocol {
    public var router: RouterProtocol {
        return self
    }
}

extension RouterProtocol {
    public func respond(request: Request) throws -> Response {
        let responder = match(request) ?? fallback
        return try responder.respond(to: request)
    }
}

public protocol Route: Responder {
    var path: String { get }
    var actions: [Method: Responder] { get }
    var fallback: Responder { get }
}

public protocol RouteMatcher {
    var routes: [Route] { get }
    init(routes: [Route])
    func match(_ request: Request) -> Route?
}

extension Route {
    public var fallback: Responder {
        return BasicResponder { _ in
            Response(status: .methodNotAllowed)
        }
    }

    public func respond(to request: Request) throws -> Response {
        let action = actions[request.method] ?? fallback
        return try action.respond(to: request)
    }
}

public final class BasicRoute: Route {
    public let path: String
    public var actions: [Method: Responder]
    public var fallback: Responder

    public init(path: String, actions: [Method: Responder] = [:], fallback: Responder = BasicRoute.defaultFallback) {
        self.path = path
        self.actions = actions
        self.fallback = fallback
    }

    public func addAction(method: Method, action: Responder) {
        actions[method] = action
    }

    public static let defaultFallback = BasicResponder { _ in
        Response(status: .methodNotAllowed)
    }
}
