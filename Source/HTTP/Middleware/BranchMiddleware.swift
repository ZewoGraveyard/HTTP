// BranchMiddleware.swift
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

public struct BranchCondition {
    public let shouldBranch: Request throws -> Bool

    public init(shouldBranch: Request throws -> Bool) {
        self.shouldBranch = shouldBranch
    }
}

public func branch(condition: BranchCondition, yes: MiddlewareType, no: MiddlewareType? = nil) -> BranchMiddleware {
    return BranchMiddleware(condition, yes: yes, no: no)
}

public struct BranchMiddleware: MiddlewareType {
    let condition: BranchCondition
    let truthy: MiddlewareType
    let falsy: MiddlewareType?

    public init(_ condition: BranchCondition, yes truthy: MiddlewareType, no falsy: MiddlewareType? = nil) {
        self.condition = condition
        self.truthy = truthy
        self.falsy = falsy
    }

    public func respond(request: Request, chain: ChainType) throws -> Response {
        if try condition.shouldBranch(request) {
            return try truthy.intercept(chain).proceed(request)
        } else {
            if let falsy = falsy {
                return try falsy.intercept(chain).proceed(request)
            } else {
                return try chain.proceed(request)
            }
        }
    }
}

