HTTP
======
[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org)
[![Platform Linux](https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

**HTTP** provides:

- HTTP request/response entities
- HTTP parser/serializer
- Protocols for HTTP server, client, router and middleware.

## Documentation

### MessageType

`MessageType` is a protocol for HTTP messages. It holds properties common to both requests and responses. `version`, `headers`, `cookies` and `body` are self-explanatory in regard to HTTP messages. `storage` is a special property that has no relationship with the HTTP protocol itself, but it's used by the framework to carry custom data between middleware and a responder in a chain.

```swift
public protocol MessageType {
    var version: Version { get set }
    var headers: Headers { get set }
    var cookies: Cookies { get set }
    var body: Body { get set }
    var storage: Storage { get set }
}
```

`MessageType` is usually not used as a parameter in our APIs. It is usually used when a computed property can be shared by both requests, and responses, like `Content-Type`, `Content-Length`, etc.

### Version

`Version` holds the version of the HTTP protocol associated with the HTTP message.

```swift
public typealias Version = (major: Int, minor: Int)
```

### Headers

The `Headers` type is a typealias for a `[HeaderName: HeaderValue]` dictionary.

```swift
public typealias Headers = [HeaderName: HeaderValue]
```

#### Accessing raw headers

The `HeaderName` type is simply a wrapper for a case insensitive key. This means you can subscript  the `headers` property without worrying if the header name is capitalized or lowercased, etc. 
 
```swift
request.headers["Content-Type"] = "application/json"
let contentType = request.headers["content-type"]
```

`contentType` will receive the value `"application/json"`.

#### Accessing headers safely
 
 
The preferred way to access values from `headers` is through type-safe computed properties defined in extensions. For example, `contentType` is a computed property shared by requests and responses that provides a type-safe wrapper for media types.

```swift
extension MessageType {
    public var contentType: MediaType? {
        get {
            if let contentType = headers["Content-Type"] {
                return MediaType(string: contentType)
            }
            return nil
        }

        set {
            headers["Content-Type"] = newValue?.description
        }
    }
}
```

So instead of accessing the raw string you can get the `MediaType` value.

```swift
response.contentType = JSONMediaType()
let contentType = response.contentType
```

`contentType` will receive the value `JSONMediaType()`.

We provide a number of type-safe computed properties in `MessageType` extensions. But if there's some header we missed, you can always extend `MessageType` yourself and create your own type-safe header 😊.

### Body

The `Body` enum can hold the HTTP body in two forms, `Buffer` or `Stream`. `Buffer` contains the whole body in binary using the [`Data`](https://github.com/Zewo/Data) struct. `Stream` contains a [`StreamType`](https://github.com/Zewo/Stream) which can be used to represent the HTTP body as a continuous stream of binary data.

```swift
public enum Body {
    case Buffer(Data)
    case Stream(StreamType)
}
```

`Body` has some computed properties to facilitate the access of the associated values.

```swift
request.body.buffer = [104, 101, 108, 108, 111]
request.body.isBuffer // true
request.body.isStream // false
request.body.stream // nil

response.body.stream = FileStream(file: someFile)
response.body.isBuffer // false
response.body.isStream // true
response.body.buffer // nil
```

### Request

`Request` is a struct that represents an HTTP request. It conforms to the `MessageType` protocol from which it inherits a number of computed properties.

```swift
public struct Request: MessageType {
    public typealias Upgrade = (Response, StreamType) throws -> Void
    public var method: Method
    public var uri: URI
    public var version: Version
    public var headers: Headers
    public var cookies: Cookies
    public var body: Body
    public var upgrade: Upgrade?
    public var storage: Storage = [:]
}
```

Besides the properties required by `MessageType`, `Request` has the `Method` and [`URI`](https://github.com/Zewo/URI) properties which represent the request line of the HTTP request.

```HTTP
GET / HTTP/1.1
```

The `Upgrade` function is used to upgrade the request to another protocol (like [`WebSocket`](https://github.com/Zewo/Websocket)) in an HTTP client.

### Response

`Response` is a struct that represents an HTTP response. It conforms to the `MessageType` protocol from which it inherits a number of computed properties.

```swift
public struct Response: MessageType {
    public typealias Upgrade = (Request, StreamType) throws -> Void
    public var status: Status
    public var version: Version
    public var headers: Headers
    public var cookies: Cookies
    public var body: Body
    public var upgrade: Upgrade?
    public var storage: Storage = [:]
}
```

Besides the properties required by `MessageType`, `Response` has the `Status` property which represents the status line of the HTTP response.

```HTTP
HTTP/1.1 200 OK
```

The `Upgrade` function is used to upgrade the response to another protocol (like [`WebSocket`](https://github.com/Zewo/Websocket)) in an HTTP server.

## Installation

```swift
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
