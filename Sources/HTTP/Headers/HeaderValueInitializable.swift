public protocol HeaderValueInitializable {
    init?(headerValue: String)
}

extension HeaderValueInitializable {
    public static func values(fromHeader header: Header?) -> [Self]? {
        guard let header = header else {
            return nil
        }
        
        let values = header.map({ Self.init(headerValue: $0) }).flatMap { $0 }
        return values.count > 0 ? values : nil
    }
}

public typealias HeaderType = protocol<HeaderValueInitializable, HeaderValueRepresentable, Equatable>
