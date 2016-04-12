extension Headers {

    /**
     The `Cache-Control` header field is used to specify directives for
     caches along the request/response chain.  Such cache directives are
     unidirectional in that the presence of a directive in a request does
     not imply that the same directive is to be given in the response.

     ## Example Headers
     `Cache-Control: no-cache`

     `Cache-Control: no-cache, no-store`

     `Cache-Control: max-age=86400`


     ## Examples
     var request =  Request()
     request.headers.cacheControl = [.noCache, .noStore]

     var response =  Response()
     response.headers.cacheControl = [.maxAge(86400)]

     - seealso: [RFC7234](https://tools.ietf.org/html/rfc7234#section-5.2)
     */
    public var cacheControl: [CacheControl]? {
        get {
            return CacheControl.values(fromHeader: headers["Cache-Control"])
        }
        set {
            headers["Cache-Control"] = newValue?.header
        }
    }
}

public enum CacheControl: Equatable {
    case maxAge(UInt)
    case maxStale(UInt)
    case minFresh(UInt)
    case mustRevalidate
    case noCache
    case noStore
    case noTransform
    case onlyIfCached
    case private_
    case proxyRevalidate
    case public_
    case sMaxAge(UInt)
}

extension CacheControl: HeaderValueInitializable {
    public init?(headerValue: String) {
        let trimmed = headerValue.trim()
        if trimmed.contains("=") {
            let split = trimmed.split("=")

            guard split.count == 2 else {
                return nil
            }

            guard let value = UInt(split[1].trim()) else {
                return nil
            }
            let key = split[0].trim()

            switch key {
            case "max-age":
                self = .maxAge(value)
            case "max-stale":
                self = .maxStale(value)
            case "min-fresh":
                self = .minFresh(value)
            case "s-maxage":
                self = .sMaxAge(value)
            default:
                return nil
            }

        } else {
            switch trimmed {
            case "must-revalidate":
                self = .mustRevalidate
            case "no-cache":
                self = .noCache
            case "no-store":
                self = .noStore
            case "no-transform":
                self = .noTransform
            case "only-if-cached":
                self = .onlyIfCached
            case "private":
                self = .private_
            case "proxy-revalidate":
                self = .proxyRevalidate
            case "public":
                self = .public_
            default:
                return nil
            }
        }
    }
}

extension CacheControl: HeaderValueRepresentable {
    public var headerValue: String {
        switch self {
        case .maxAge(let age):
            return "max-age=\(age)"
        case .maxStale(let age):
            return "max-stale=\(age)"
        case .minFresh(let age):
            return "min-fresh=\(age)"
        case .mustRevalidate:
            return "must-revalidate"
        case .noCache:
            return "no-cache"
        case .noStore:
            return "no-store"
        case .noTransform:
            return "no-transform"
        case .onlyIfCached:
            return "only-if-cached"
        case .private_:
            return "private"
        case .proxyRevalidate:
            return "proxy-revalidate"
        case .public_:
            return "public"
        case .sMaxAge(let age):
            return "s-maxage=\(age)"
        }
    }
}

public func ==(lhs: CacheControl, rhs: CacheControl) -> Bool {
    return lhs.headerValue == rhs.headerValue
}
