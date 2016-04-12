extension Headers {

    /** 
        The `ETag` header field in a response provides the current entity-tag
        for the selected representation, as determined at the conclusion of
        handling the request.  An entity-tag is an opaque validator for
        differentiating between multiple representations of the same
        resource, regardless of whether those multiple representations are
        due to resource state changes over time, content negotiation
        resulting in multiple representations being valid at the same time,
        or both.  An entity-tag consists of an opaque quoted string, possibly
        prefixed by a weakness indicator.

        ## Example Headers
        `ETag: "xyzzy"`

        `ETag: W/"xyzzy"`

        ## Examples
            var response =  Response()
            response.headers.eTag = EntityTag(tag: "xyzzy")
            // Outputs ETag: "xyzzy"

            var response =  Response()
            response.headers.eTag = EntityTag(tag: "xyzzy", weak: true)
            // Outputs ETag: W/"xyzzy"

        - seealso: [RFC7232](http://tools.ietf.org/html/rfc7232#section-2.3)
    */
    public var eTag: EntityTag? {
        get {
            return headers["ETag"]?.first.flatMap({ EntityTag(headerValue: $0) })
        }
        set {
            headers["Etag"] = newValue?.header
        }
    }
}
