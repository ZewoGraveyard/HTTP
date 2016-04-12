extension Headers {

    /**
        The `Content-Encoding` header field indicates what content codings
        have been applied to the representation, beyond those inherent in the
        media type, and thus what decoding mechanisms have to be applied in
        order to obtain data in the media type referenced by the Content-Type
        header field.  `Content-Encoding` is primarily used to allow a
        representation's data to be compressed without losing the identity of
        its underlying media type.

        ## Example Headers
        `Content-Encoding: gzip`


        ## Examples
            var response =  Response()
            response.headers.contentEncoding = [.gzip]

        - seealso: [RFC7231](https://tools.ietf.org/html/rfc7231#section-3.1.2.2)
    */
    public var contentEncoding: [Encoding]? {
        get {
            return Encoding.values(fromHeader: headers["Content-Encoding"])
        }
        set {
            headers["Content-Encoding"] = newValue?.header
        }
    }
}
