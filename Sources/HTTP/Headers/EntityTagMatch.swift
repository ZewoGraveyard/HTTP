public enum EntityTagMatch: Equatable {
    case any
    case tags([EntityTag])
}

extension EntityTagMatch {
    public init?(header: Header) {
        guard let first = header.first else {
            return nil
        }

        if first == "*" {
            self = .any
        } else {
            if let tags = EntityTag.values(fromHeader: header) {
                self = .tags(tags)
            } else {
                return nil
            }
        }
    }
}

extension EntityTagMatch: HeaderValueRepresentable {
    public var headerValue: String {
        return ""
    }

    public var header: Header {
        switch self {
        case .any:
            return "*"
        case .tags(let tags):
            return tags.header
        }
    }
}

public func ==(lhs: EntityTagMatch, rhs: EntityTagMatch) -> Bool {
    switch (lhs, rhs) {
    case (.any, .any):
        return true
    case (.tags(let lhsTags), .tags(let rhsTags)):
        return lhsTags == rhsTags
    default:
        return false
    }
}
