//
//  String+Extension.swift
//  AAShare
//
//  Created by Chen Tom on 16/01/2017.
//  Copyright © 2017 Chen Zheng. All rights reserved.
//


//
// Strings in Swift 3
// https://oleb.net/blog/2016/08/swift-3-strings/
//

import Foundation

/*
 var greeting = "Hello, world!"
 greeting.dropFirst(7) // → "world!"
 */
extension String: Collection {
    // Nothing needed here – it already has the necessary implementations
}

extension String {
    
    /*
     s[5] // → "f"
     */
    subscript(idx: Int) -> Character {
        guard let strIdx = index(startIndex, offsetBy: idx, limitedBy: endIndex)
            else { fatalError("String index out of bounds") }
        return self[strIdx]
    }
    
    /*
     let s = "Wow! This contains _all_ kinds of things like 123 and \"quotes\"?"
     s.words()
     // → ["Wow", "This", "contains", "all", "kinds", "of", "things", "like", "123", "and", "quotes"]
     */
    func words(with charset: CharacterSet = .alphanumerics) -> [String] {
        return self.unicodeScalars.split {
            !charset.contains($0)
            }.map(String.init)
    }
    
    
    /*
     let paragraph = "The quick brown fox jumped over the lazy dog."
     paragraph.wrapped(after: 15)
     // → "The quick brown\nfox jumped over\nthe lazy dog."
     */
    func wrapped(after: Int = 70) -> String {
        var i = 0
        let lines = self.characters.split(omittingEmptySubsequences: false) { character in
            switch character {
            case "\n",
                 " " where i >= after:
                i = 0
                return true
            default:
                i += 1
                return false
            }
            }.map(String.init)
        return lines.joined(separator: "\n")
    }
    
    
    /*
     二进制转十进制
     binary2dec("1111")        返回为15
     */
    func binary2dec(num:String) -> Int {
        var sum = 0
        for c in num.characters {
            sum = sum * 2 + Int("\(c)")!
        }
        return sum
    }
    
    /*
     十六进制转十进制
     hex2dec("f")
     */
    func hex2dec(num:String) -> Int {
        let str = num.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
    
    
}
