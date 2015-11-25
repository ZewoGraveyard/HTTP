// String+Curvature.swift
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

extension String {
    func splitBy(separator: Character, allowEmptySlices: Bool = false) -> [String] {
        return characters.split(allowEmptySlices: allowEmptySlices) { $0 == separator }.map { String($0) }
    }

    func trim() -> String {
        return stringByTrimmingCharactersInSet(CharacterSet.whitespaceAndNewline)
    }

    func stringByTrimmingCharactersInSet(characterSet: Set<Character>) -> String {
        let string = stringByTrimmingFromStartCharactersInSet(characterSet)
        return string.stringByTrimmingFromEndCharactersInSet(characterSet)
    }

    private func stringByTrimmingFromStartCharactersInSet(characterSet: Set<Character>) -> String {
        var trimStartIndex: Int = characters.count

        for (index, character) in characters.enumerate() {
            if !characterSet.contains(character) {
                trimStartIndex = index
                break
            }
        }

        return self[startIndex.advancedBy(trimStartIndex) ..< endIndex]
    }

    private func stringByTrimmingFromEndCharactersInSet(characterSet: Set<Character>) -> String {
        var trimEndIndex: Int = characters.count

        for (index, character) in characters.reverse().enumerate() {
            if !characterSet.contains(character) {
                trimEndIndex = index
                break
            }
        }

        return self[startIndex ..< startIndex.advancedBy(characters.count - trimEndIndex)]
    }
}

struct CharacterSet {
    static var whitespaceAndNewline: Set<Character> {
        return [" ", "\n"]
    }
}