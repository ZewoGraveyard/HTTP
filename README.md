HTTP
======
[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org)
[![Platform Linux](https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

**HTTP** provides:

- HTTP request/response entities
- HTTP parser/serializer
- Protocols for HTTP servers, HTTP clients and middleware.

## Usage

### MessageType

`MessageType` is a protocol for HTTP messages (request/response). It holds properties common to both requests and responses, specially the `headers` and the `body`. `storage` is a special property that has no relationship with the HTTP protocol, but it's used by the framework to carry custom data between middleware and responders.

```
public protocol MessageType {
    var version: (major: Int, minor: Int) { get set }
    var headers: Headers { get set }
    var body: Body { get set }
    var storage: [String: Any] { get set }
}
```

### Headers

The `Headers` type is a typealias for a `[Header: String]` dictionary.

```
public typealias Headers = [Header: String]
```

 The `Header` type is simply a wrapper for a case insensitive key. This means you can subscript  the `headers` property without worrying if the header name is capitalized or lowercased, etc. 
 
 ```
 request.headers["Content-Type"]
 request.headers["content-type"]
 ```
 
 Both examples will give you the correct header value.

### Body

The `Body` enum can hold the HTTP body in two forms, `Buffer` or `Stream`. `Buffer` contains the whole body in binary using the [`Data`](https://github.com/Zewo/Data) struct. `Stream` contains a [`StreamType`](https://github.com/Zewo/Stream) which can be used to represent the HTTP body as a continuous stream of binary data.

```
public enum Body {
    case Buffer(Data)
    case Stream(StreamType)
}

```

### Request

`Request` is a struct that represents the HTTP request. It conforms to the `MessageType` protocol, from which it inherits a number of computed properties related to the headers and body. Besides the properties required by `MessageType`, `Request` has the `Method` and [`URI`](https://github.com/Zewo/URI) properties, which form the request line. The `Upgrade` function is used to upgrade the request in an HTTP client. 

```
public struct Request: MessageType {
    public typealias Upgrade = (Response, StreamType) throws -> Void
    public var method: Method
    public var uri: URI
    public var version: (major: Int, minor: Int)
    public var headers: Headers
    public var body: Body
    public var upgrade: Upgrade?
    public var storage: [String: Any] = [:]
}
```

## Installation

```
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 2)
    ]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

License
-------

**HTTP** is released under the MIT license. See LICENSE for details.
