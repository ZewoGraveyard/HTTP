HTTP
======

[![Swift][swift-badge]][swift-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]

**HTTP** provides:

- HTTP request/response entities
- HTTP parser/serializer
- Protocols for HTTP server, client, router and middleware.

## Documentation

### MessageType

`MessageType` is a protocol for HTTP messages. It holds properties common to both requests and responses.

```swift
public protocol MessageType {
    var version: Version { get set }
    var headers: Headers { get set }
    var cookies: Cookies { get set }
    var body: Body { get set }
    var storage: Storage { get set }
}
```

`version`, `headers`, `cookies` and `body` are self-explanatory in regard to HTTP messages. `storage` is a special property that has no relationship with the HTTP protocol itself, but it's used by the framework to carry custom data between middleware and a responder in a chain. `MessageType` is usually not used as a parameter in our APIs. It is mostly used when a computed property can be shared by both requests, and responses, like `contentType`, `contentLength`, etc.

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
if let contentType = request.headers["content-type"] {
    // do something with contentType
}
```

`contentType` will receive the value `"application/json"`.

#### Accessing `headers` safely
 
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
response.contentType = JSONMediaType
if let contentType = response.contentType {
    // do something with contentType
}
```

`contentType` will receive the value `JSONMediaType`.

We provide a number of type-safe computed properties in `MessageType` extensions. But if there's some header we missed, you can always extend `MessageType` yourself and create your own type-safe header 😊.

### Cookies

The `Cookies` type is a typealias for `Set<Cookie>`.

```swift
public typealias Cookies = Set<Cookie>
```

Cookies are handled differently than other HTTP headers specially because of the `Set-Cookie` header. The `Cookie` type has two required properties `name` and `value` and six optional properties; `expires`, `maxAge`, `domain`, `path`, `secure`, `HTTPOnly`.

```swift
let cookies: Cookies = [
    Cookie(name: "color", value: "blue"),
    Cookie(name: "token", value: "21AXC3QPQK", secure: true, HTTPOnly: true),
    Cookie(name: "theme", value: "dark", expires: "Wed, 08 Jul 2018 23:10:34 GMT"),
    Cookie(name: "token", value: "A8J3FB208S", maxAge: 60 * 60),
    Cookie(name: "color", value: "magenta", domain: ".zewo.io", path: "/"),
]
```

> **Warning**: When setting `cookies` on a `Request` the attributes will be ignored by the HTTP parser/serializer as they're only valid for `Set-Cookie` headers on an HTTP response.

### Body

The `Body` enum can represent the HTTP body in two forms, `Buffer` or `Stream`. `Buffer` holds a [`Data`](https://github.com/Zewo/Data) struct containing the whole body. `Stream` contains any value that conforms to the [`StreamType`](https://github.com/Zewo/Stream) protocol, which represents a continuous stream of binary data.

```swift
public enum Body {
    case Buffer(Data)
    case Stream(StreamType)
}
```

`Body` has some computed properties to facilitate the access of associated values.

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

### Storage

The `storage` property is used to store custom data in the HTTP message. It is used to pass data between middlewares and responders.

```swift
request.storage["user"] = User(name: John)
if let user = request.storage["user"] as? User {
    // do something with user
}
```

> **Warning**: Unlike `headers`, `storage`'s keys are case sensitive. So be careful and subscript `storage` with the same key you used to store the value.

#### Accessing `storage` safely

Just like `header`, the preferred way to access values from the `storage` is through type-safe computed properties defined in extensions.

```swift
extension Request {
    public var user: User? {
        get {
            return storage["user"] as? User
        }

        set {
            storage["user"] = newValue
        }
    }
}
```

This way you don't need to type-cast when unwrapping the value and you get a cleaner and safer API.

```swift
request.user = User(name: John)
if let user = request.user {
    // do something with user
}
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

### Creating a `Request`

When you're on the client side you have to create a `Request` to send it to an HTTP server. There are plenty of initializers for a `Request`. Here are some examples.

```swift
// using URI with path
let uri = URI(path: "/")
let request = Request(method: .GET, uri: uri)

// using URI with path and query
let uri = URI(
	path: "/users",
	query: [
		"count": "10"
	]
)
let request = Request(method: .GET, uri: uri)

// using headers and uri as String
let headers: Headers = [
	"Connection": "close"
]
let request = try Request(method: .GET, uri: "/users?count=10", headers: headers)

// using cookies
let cookies: Cookies = [
    Cookie(name: "color", value: "blue")
]
let request = try Request(method: .GET, uri: "/", cookies: cookies)

// using body as a buffer with Data
let hello: Data = [104, 101, 108, 108, 111]
let request = try Request(method: .POST, uri: "/hello", body: hello)

// using body as a buffer with DataConvertible (String)
let request = try Request(method: .POST, uri: "/hello", body: "hello")

// using body as a buffer with DataConvertible (JSON)
let json: JSON = [
	"hello": "world"
]
let request = try Request(method: .POST, uri: "/hello", body: json)

// using body as a stream
let fileStream = FileStream(file: file)
let request = try Request(method: .POST, uri: "/hello", body: fileStream)
```

Sometimes you want to upgrade your request to another protocol like [`WebSocket`](https://github.com/Zewo/Websocket). You can take full control of the transport stream after the `Response` if you provide an `Upgrade` function.

```swift
let request = Request(method: .GET, uri: "/") { response, stream in
    // here you can do whatever you want with the transport stream
}
```

> **Warning**: Don't confuse the *body* stream with the *transport* stream. The *body* stream is used to send/receive binary data in the HTTP message body. While *transport* stream is the raw stream of binary data sent/received from the client and server. After you upgrade you can use the *transport* stream to communicate in any other protocol you want.

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
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 4)
    ]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

License
-------

**HTTP** is released under the MIT license. See LICENSE for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[platform-badge]: https://img.shields.io/badge/Platform-Mac%20%26%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io