/**
    Many of the request header fields for proactive negotiation use a
    common parameter, named "q" (case-insensitive), to assign a relative
    "weight" to the preference for that associated kind of content.  This
    weight is referred to as a "quality value" (or "qvalue") because the
    same parameter name is often used within server configurations to
    assign a weight to the relative quality of the various
    representations that can be selected for a resource.

    The weight is normalized to a real number in the range 0 through 1,
    where 0.001 is the least preferred and 1 is the most preferred; a
    value of 0 means "not acceptable".  If no "q" parameter is present,
    the default weight is 1.

    A sender of qvalue MUST NOT generate more than three digits after the
    decimal point.  User configuration of these values ought to be
    limited in the same fashion.

    Because of the limitations on the number of decimal places, it is easier
    to represent the quality value internally as a `UInt16` between 0 and 1000,
    where 0 is "not acceptable" and 1000 is "most preferred".

    - seealso: [RFC7231](https://tools.ietf.org/html/rfc7231#section-5.3.1)
*/
public struct QualityValue<Element: HeaderType>: Equatable {
    let quality: UInt16
    let value: Element

    init(value: Element, quality: UInt16 = 1000) {
        self.value = value
        self.quality = quality > 1000 ? 1000 : quality
    }

    private var qualityString: String {
        if quality == 1000 {
            return "1"
        } else if quality == 0 {
            return "0"
        } else {
            return String(format: "0.%03u", quality)
        }
    }
}

extension QualityValue: HeaderValueRepresentable {
    public var headerValue: String {
        return quality == 1000 ? value.headerValue : "\(value.headerValue);q=\(qualityString)"
    }
}

extension QualityValue: HeaderValueInitializable {
    public init?(headerValue: String) {
        var split = headerValue.split(";")

        if split.count >= 2 {
            // Q value could be any of the values
            if let qIndex = split.index(where: { $0.hasPrefix("Q=") || $0.hasPrefix("q=") }) {

                // Create Q Value first, and remove that value from the array
                let qString = split.remove(at: qIndex)
                let floatString = qString[qString.startIndex.advanced(by: 2)..<qString.endIndex]

                guard let qFloat = Float(floatString) else {
                    return nil
                }
                let qValue = qualityValueFromFloat(qFloat)


                // Once Q Value is parsed, recreate header string with it removed
                let newHeaderValue = split.joined(separator: ";")


                if let value = Element(headerValue: newHeaderValue.trim()) {
                    self = QualityValue(value: value, quality: qValue)
                } else {
                    return nil
                }

            } else {
                if let value = Element(headerValue: headerValue.trim()) {
                    self = QualityValue(value: value, quality: 1000)
                } else {
                    return nil
                }
            }
        } else {
            if let value = Element(headerValue: headerValue.trim()) {
                self = QualityValue(value: value, quality: 1000)
            } else {
                return nil
            }
        }
    }
}

public func == <E:HeaderType> (lhs:QualityValue<E>, rhs:QualityValue<E>) -> Bool {
    return lhs.quality == rhs.quality && lhs.value == rhs.value
}

private func qualityValueFromFloat(float: Float) -> UInt16 {
    if float <= 0.0 {
        return 0
    } else if float >= 1.0 {
        return 1000
    } else {
        return UInt16(float * 1000)
    }
}
