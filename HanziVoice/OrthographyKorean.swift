//
//  OrthographyKorean.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/22.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

struct OrthographyKorean : OrthographyImpl {
    enum DisplayType {
        case hangul
        case romanization //database representation
    }
    static let firstHangul:UInt32 = 0xAC00
    static let lastHangul:UInt32 = 0xD7A3
    static let hanguls = CharacterSet(charactersIn:
        UnicodeScalar(firstHangul)!...UnicodeScalar( lastHangul)!)
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
    
    func isHangul(_ codepoint:UInt32) -> Bool {
        return codepoint >= OrthographyKorean.firstHangul && codepoint <= OrthographyKorean.lastHangul
    }
    
    func display(_ s:String) -> String {
        return self.display(s, as: .hangul)
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
        let codePoint =
            Int(OrthographyKorean.firstHangul) +
            (initialOffset * vowels.count + vowelOffset) * finals.count +
            finalOffset
        
        if let scalar = UnicodeScalar(codePoint) {
            return "\(scalar)"
        } else {
            return s
        }
    }
    
//    //todo: translate java to swift
//    func canonicalize(_ string: String) -> String {
//        // Input can be either a hangul, or non-canonicalized romanization
//        if (s == null || s.length() == 0) return s;
//        char unicode = s.charAt(0);
//        if (isHangul(unicode)) {    // Hangul
//            unicode -= FIRST_HANGUL;
//            int z = unicode % finals.length;
//            int x = unicode / finals.length;
//            int y = x % vowels.length;
//            x /= vowels.length;
//            return initials[x] + vowels[y] + finals[z];
//        }
//        else {      // Romanization, do some obvious corrections
//            if (s.startsWith("l")) s = "r" + s.substring(1);
//            else if (s.startsWith("gg")) s = "kk" + s.substring(2);
//            else if (s.startsWith("dd")) s = "tt" + s.substring(2);
//            else if (s.startsWith("bb")) s = "pp" + s.substring(2);
//            s = s.replace("weo", "wo").replace("oi", "oe").replace("eui", "ui");
//            if (s.endsWith("r")) s = s.substring(0, s.length() - 1) + "l";
//            else if (s.endsWith("g") && !s.endsWith("ng")) s = s.substring(0, s.length() - 1) + "k";
//            else if (s.endsWith("d")) s = s.substring(0, s.length() - 1) + "t";
//            else if (s.endsWith("b")) s = s.substring(0, s.length() - 1) + "p";
//            return s;
//        }
//    }
    
    func splitForSearch(_ string: String, options: MCPSearchOptions) -> [String] {
        let hanguls = string
            .unicodeScalars
            .filter { OrthographyKorean.hanguls.contains($0) }
            .map { String($0) }
        let nonHanguls = string
            .components(separatedBy: OrthographyKorean.hanguls)
        return hanguls + nonHanguls
    }
}
