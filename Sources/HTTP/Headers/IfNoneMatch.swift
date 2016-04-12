extension Headers {

    /**
        The `If-None-Match` header field makes the request method conditional
        on a recipient cache or origin server either not having any current
        representation of the target resource, when the field-value is `*`,
        or having a selected representation with an entity-tag that does not
        match any of those listed in the field-value.

        A recipient MUST use the weak comparison function when comparing
        entity-tags for 1If-None-Match1 [(Section 2.3.2)](http://tools.ietf.org/html/rfc7232#section-2.3.2), 
        since weak entity-tags
        can be used for cache validation even if there have been changes to
        the representation data.


        ## Example Headers
        `If-None-Match: W/"xyzzy"`

        `If-None-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"`

        `If-None-Match: *`


        ## Examples
            var request =  Request()
            request.headers.ifNoneMatch = .Tags([EntityTag(tag: "xyzzy", weak : true)])

            var request =  Request()
            request.headers.ifNoneMatch = .Tags([EntityTag(tag: "xyzzy"), EntityTag(tag: "r2d2xxxx"), EntityTag(tag: "c3piozzzz")])

            var request =  Request()
            request.headers.ifNoneMatch = .Any


        - seealso: [RFC7232](https://tools.ietf.org/html/rfc7232#section-3.2)
    */
    public var ifNoneMatch: EntityTagMatch? {
        get {
            if let headerValues = headers["If-None-Match"] {
                return EntityTagMatch(header: headerValues)
            }
            return nil
        }
        set {
            headers["If-None-Match"] = newValue?.header
        }
    }
}
