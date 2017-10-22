//
//  OrthographyKorean.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/22.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

struct OrthographyKorean {
    enum DisplayType {
        case hangul
        case romanization //database representation
    }
    let firstHangul:Int = 0xAC00
    let lastHangul:Int = 0xD7A3
    let initials = ["g", "kk", "n", "d", "tt", "r", "m", "b", "pp", "s", "ss", "", "j", "jj", "ch", "k", "t", "p", "h"]
    let vowels = ["a", "ae", "ya", "yae", "eo", "e", "yeo", "ye", "o", "wa", "wae", "oe", "yo", "u", "wo", "we", "wi", "yu", "eu", "ui", "i"]
    let finals = ["", "k", "kk0", "ks0", "n", "nj0", "nh0", "d0", "l", "lg0", "lm0", "lb0", "ls0", "lt0", "lp0", "lh0", "m", "p", "bs0", "s0", "ss0", "ng", "j0", "ch0", "k0", "t0", "p0", "h0"]
    var mapInitials:[String:Int] = [:] //Int is index to the array
    var mapVowels:[String:Int] = [:] //Int is index to the array
    var mapFinals:[String:Int] = [:] //Int is index to the array
     init() {
        for (idx, str) in initials.enumerated() {
            mapInitials[str] = idx
        }
        for (idx, str) in vowels.enumerated() {
            mapVowels[str] = idx
        }
        for (idx, str) in finals.enumerated() {
            mapFinals[str] = idx
        }
    }
    func display(_ s:String, as type: DisplayType = .hangul) -> String {
        //only support from romanization to hangul
        if type == .romanization {
            return s
        }
        //romanized char: $initial[1,2] $vowel $final[1,2]
        //initials
        var initialOffset:Int = mapInitials[""]!
        var vowelOffset:Int!
        var finalOffset:Int = mapFinals[""]!
        var vowelBeginIndex = s.startIndex
        var vowelEndIndex = s.endIndex
        
        for idx in [2,1] {
            if let index = s.index(s.startIndex, offsetBy: idx, limitedBy: s.endIndex),
                let codeOffset = mapInitials[s.substring(to: index)] {
                vowelBeginIndex = index
                initialOffset = codeOffset
                break
            }
        }
        //finals
        for idx in [-2,-1] {
            if let index = s.index(s.endIndex, offsetBy: idx, limitedBy: s.startIndex),
                let codeOffset = mapFinals[s.substring(from: index)] {
                vowelEndIndex = index
                finalOffset = codeOffset
                break
            }
        }
        //vowels
        vowelOffset = mapVowels[s.substring(with: vowelBeginIndex..<vowelEndIndex)]
        if vowelOffset == nil {
            //fail to find vowel!
            return s
        }
        
        //here: 3 components found, ok to make char and return
        let codePoint = firstHangul +
            (initialOffset * vowels.count + vowelOffset) * finals.count +
        finalOffset
        if let scalar = UnicodeScalar(codePoint) {
            return "\(scalar)"
        } else {
            return s
        }
    }
}
