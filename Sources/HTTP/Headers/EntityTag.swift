/**
    An entity-tag is an opaque validator for
    differentiating between multiple representations of the same
    resource, regardless of whether those multiple representations are
    due to resource state changes over time, content negotiation
    resulting in multiple representations being valid at the same time,
    or both.  An entity-tag consists of an opaque quoted string, possibly
    prefixed by a weakness indicator.

    An entity-tag can be either a weak or strong validator, with strong
    being the default.  If an origin server provides an entity-tag for a
    representation and the generation of that entity-tag does not satisfy
    all of the characteristics of a strong validator 
    [(Section 2.1)](http://tools.ietf.org/html/rfc7232#section-2.1) , then
    the origin server MUST mark the entity-tag as weak by prefixing its
    opaque value with "W/" (case-sensitive).

    - seealso: [RFC7232](http://tools.ietf.org/html/rfc7232#section-2.3)
*/
public struct EntityTag: Equatable {
    public let tag: String
    public let weak: Bool

    public init(tag: String, weak: Bool = false) {
        self.tag = tag
        self.weak = weak
    }
}

extension EntityTag: HeaderValueInitializable {
    public init?(headerValue string: String) {
        guard string.hasSuffix("\"") && string.utf8.count >= 2 else {
            return nil
        }

        if string.hasPrefix("W/\"") && string.utf8.count >= 4 && validateEntityTag(string.between("W/\"", "\"")!) {
            self.tag = string.between("W/\"", "\"")!
            self.weak = true
        } else if string.hasPrefix("\"") && validateEntityTag(string.between("\"", "\"")!)  {
            self.tag = string.between("\"", "\"")!
            self.weak = false
        } else {
            return nil
        }
    }
}

extension EntityTag: HeaderValueRepresentable {
    public var headerValue: String {
        if weak {
            return "W/\"\(tag)\""
        } else {
            return "\"\(tag)\""
        }
    }
}

extension EntityTag {
    public func weakComparison(toEntityTag eTag: EntityTag) -> Bool {
        return tag == eTag.tag
    }

    public func strongComparison(toEntityTag eTag: EntityTag) -> Bool {
        return (tag == eTag.tag) && (!weak) && (!eTag.weak)
    }
}

public func ==(lhs: EntityTag, rhs: EntityTag) -> Bool {
    return lhs.tag == rhs.tag && lhs.weak == rhs.weak
}

private func validateEntityTag(tag: String) -> Bool {
    let bytes = [UInt8](tag.utf8)

    for byte in bytes {
        if byte == 0x21 || (byte >= 0x23 && byte <= 0x7e) || (byte >= 0x80 && byte <= 0xff) {
            
        } else {
            return false
        }
    }
    return true
}

// TODO: Find better way to do this
extension String {
    func between(left: String, _ right: String) -> String? {
        var string = self

        string.replace(left, with: "")
        string.replace(right, with: "")

        return string
    }
}
