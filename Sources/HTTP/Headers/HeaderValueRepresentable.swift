public protocol HeaderValueRepresentable: HeaderRepresentable {
    var headerValue: String { get }
}

extension HeaderValueRepresentable {
    public var header: Header {
        return Header(self.headerValue)
    }
}

extension Sequence where Iterator.Element: HeaderValueRepresentable {
    var header: Header {
        return Header(self.map({ $0.headerValue }))
    }
}
