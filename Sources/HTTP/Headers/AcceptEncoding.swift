extension Headers {

    /**
        The `Accept-Encoding` header field can be used by user agents to
        indicate what response content-codings are acceptable 
        in the response.  An `identity` token is used as a synonym
        for "no encoding" in order to communicate when no encoding is
        preferred.


        ## Example Headers
        `Accept-Encoding: compress, gzip`

        `Accept-Encoding: *`

        `Accept-Encoding: compress;q=0.5, gzip;q=1.0`


        ## Examples
        var request =  Request()
        request.headers.acceptEncoding = [QualityValue(value: .compress), QualityValue(value: .gzip)]
     
        var request =  Request()
        request.headers.acceptEncoding = [QualityValue(value: .custom("*"))]
     
        var request =  Request()
        request.headers.acceptEncoding = [QualityValue(value: .compress, quality: 500), QualityValue(value: .gzip, quality: 1000)]


        - seealso: [RFC7231](https://tools.ietf.org/html/rfc7231#section-5.3.4)
     */
    public var acceptEncoding: [QualityValue<Encoding>]? {
        get {
            return QualityValue<Encoding>.values(fromHeader: headers["Accept-Encoding"])
        }
        set {
            headers["Accept-Encoding"] = newValue?.header
        }
    }
}
