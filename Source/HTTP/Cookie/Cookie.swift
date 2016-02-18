// Cookie.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

public enum CookieError: ErrorType {
    case InvalidString
}

public struct Cookie {
    public var name: String
    public var value: String
    public var attributes: [String: String]

    init(name: String, value: String, attributes: [String: String]) {
        self.name = name
        self.value = value
        self.attributes = attributes
    }

    public init(name: String, value: String) {
        self.init(
            name: name,
            value: value,
            attributes: [:]
        )
    }
}

extension Cookie: CustomStringConvertible {
    public var description: String {
        var string = "\(name)=\(value)"

        if attributes.count > 0 {
            string += attributes.reduce("") {
                if $1.1 != "" {
                    return $0 + "; \($1.0)=\($1.1)"
                } else {
                    return $0 + "; \($1.0)"
                }
            }
        }

        return string
    }
}

extension Cookie {
    public static func parseCookie(string: String) throws -> Cookies {
        var cookies = Cookies()
        let tokens = string.split(";")

        for i in 0 ..< tokens.count {
            let cookieTokens = tokens[i].split("=", maxSplit: 1)

            if cookieTokens.count != 2 {
                throw CookieError.InvalidString
            }

            cookies.append(Cookie(name: cookieTokens[0].trim(), value: cookieTokens[1].trim()))
        }

        return cookies
    }

    public static func parseSetCookie(string: String) throws -> Cookie {
        let cookieStringTokens = string.split(";")

        let cookieTokens = cookieStringTokens[0].split("=")

        if cookieTokens.count != 2 {
            throw CookieError.InvalidString
        }

        let name = cookieTokens[0]
        let value = cookieTokens[1]

        var attributes: [String: String] = [:]

        for i in 1 ..< cookieStringTokens.count {
            let attributeTokens = cookieStringTokens[i].split("=")

            if attributeTokens.count > 2 {
                throw CookieError.InvalidString
            }

            if attributeTokens.count == 1 {
                attributes[attributeTokens[0].trim()] = ""
            } else {
                attributes[attributeTokens[0].trim()] = attributeTokens[1].trim()
            }
        }

        return Cookie(name: name, value: value, attributes: attributes)
    }
}