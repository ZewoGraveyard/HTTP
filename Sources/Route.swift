public protocol Route: Responder {
    var path: String { get }
    var actions: [Method: Responder] { get }
    var fallback: Responder { get }
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

    public func addAction(method method: Method, action: Responder) {
        actions[method] = action
    }

    public static let defaultFallback = BasicResponder { _ in
        Response(status: .methodNotAllowed)
    }
}