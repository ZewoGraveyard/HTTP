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