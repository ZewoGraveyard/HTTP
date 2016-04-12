extension Headers {

    /**
        The `If-Match` header field makes the request method conditional on
        the recipient origin server either having at least one current
        representation of the target resource, when the field-value is `*`,
        or having a current representation of the target resource that has an
        entity-tag matching a member of the list of entity-tags provided in
        the field-value.

        An origin server MUST use the strong comparison function when
        comparing entity-tags for `If-Match` [(Section 2.3.2)](http://tools.ietf.org/html/rfc7232#section-2.3.2), 
        since the client
        intends this precondition to prevent the method from being applied if
        there have been any changes to the representation data.

        ## Example Headers
        `If-Match: "xyzzy"`

        `If-Match: "xyzzy", "r2d2xxxx", "c3piozzzz"`

        `If-Match: *`

        ## Examples
            var request =  Request()
            request.headers.ifMatch = .Tags([EntityTag(tag: "xyzzy")])

            var request =  Request()
            request.headers.ifMatch = .Tags([EntityTag(tag: "xyzzy"), EntityTag(tag: "r2d2xxxx"), EntityTag(tag: "c3piozzzz")])

            var request =  Request()
            request.headers.ifMatch = .Any

        - seealso: [RFC7232](https://tools.ietf.org/html/rfc7232#section-3.1)
    */
    public var ifMatch: EntityTagMatch? {
        get {
            if let headerValues = headers["If-Match"] {
                return EntityTagMatch(header: headerValues)
            }
            return nil
        }
        set {
            headers["If-Match"] = newValue?.header
        }
    }
}
