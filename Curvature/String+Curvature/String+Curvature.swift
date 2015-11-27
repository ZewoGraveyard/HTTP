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
    public init?(URLEncodedString: String) {
        let spaceCharacter: UInt8 = 32
        let percentCharacter: UInt8 = 37
        let plusCharacter: UInt8 = 43

        var encodedData: [UInt8] = [] + URLEncodedString.utf8
        var decodedData: [UInt8] = []

        for var i = 0; i < encodedData.count; {
            let currentCharacter = encodedData[i]

            switch currentCharacter {
            case percentCharacter:
                let unicodeA = UnicodeScalar(encodedData[i + 1])
                let unicodeB = UnicodeScalar(encodedData[i + 2])

                let hexString = "\(unicodeA)\(unicodeB)"

                guard let character = Int(hexString: hexString) else {
                    return nil
                }

                decodedData.append(UInt8(character))
                i += 3

            case plusCharacter:
                decodedData.append(spaceCharacter)
                i++

            default:
                decodedData.append(currentCharacter)
                i++
            }
        }

        self.init(data: decodedData)
    }

    public init?(data: [Int8]) {
        if let string = String.fromCString(data + [0]) {
            self.init(string)
        }
        return nil
    }

    public init?(data: [UInt8]) {
        var string = ""
        var decoder = UTF8()
        var generator = data.generate()
        var finished = false

        while !finished {
            let decodingResult = decoder.decode(&generator)
            switch decodingResult {
            case .Result(let char): string.append(char)
            case .EmptyInput: finished = true
            case .Error: return nil
            }
        }

        self.init(string)
    }

    var data: [Int8] {
        return self.utf8.map { Int8($0) }
    }

    public func splitBy(separator: Character, allowEmptySlices: Bool = false) -> [String] {
        return characters.split(allowEmptySlices: allowEmptySlices) { $0 == separator }.map { String($0) }
    }

    public func trim() -> String {
        return stringByTrimmingCharactersInSet(CharacterSet.whitespaceAndNewline)
    }

    public func stringByTrimmingCharactersInSet(characterSet: Set<Character>) -> String {
        let string = stringByTrimmingFromStartCharactersInSet(characterSet)
        return string.stringByTrimmingFromEndCharactersInSet(characterSet)
    }

    public  func stringByTrimmingFromStartCharactersInSet(characterSet: Set<Character>) -> String {
        var trimStartIndex: Int = characters.count

        for (index, character) in characters.enumerate() {
            if !characterSet.contains(character) {
                trimStartIndex = index
                break
            }
        }

        return self[startIndex.advancedBy(trimStartIndex) ..< endIndex]
    }

    public  func stringByTrimmingFromEndCharactersInSet(characterSet: Set<Character>) -> String {
        var endIndex: Int = characters.count

        for (index, character) in characters.reverse().enumerate() {
            if !characterSet.contains(character) {
                endIndex = index
                break
            }
        }

        return self[startIndex ..< startIndex.advancedBy(characters.count - endIndex)]
    }
}

public struct CharacterSet {
    public static var whitespaceAndNewline: Set<Character> {
        return [" ", "\n"]
    }
}