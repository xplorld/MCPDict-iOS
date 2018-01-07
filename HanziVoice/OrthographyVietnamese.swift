//
//  OrthographyVietnamese.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/11/1.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

class OrthographyVietnamese: OrthographyInstance {
    
    enum DisplayType {
        case old
        case new
    }
    
    // combined -> base
    var baseMap: [String:String] = [:]
    // combined -> tone
    var toneMap: [String:String] = [:]
    // base+tone -> combined
    var combinedMap: [String:String] = [:]
    
    init() {
        for row in Orthography.readCSV(filename: "orthography_vn",ofType: "tsv",length: 3) {
            //#Combined, base, tone
            baseMap[row[0]] = row[1]
            toneMap[row[0]] = row[2]
            combinedMap[row[1] + row[2]] = row[0]
        }
    }
    
    func canonicalize(_ string: String) -> String {
        guard !string.isEmpty else { return string }
        var chars = string.characters
        var tone = ""
        var stem = ""
        //1. initial "tr"
        if string.hasPrefix("tr") {
            stem += "tr"
            chars = chars.dropFirst(2)
        }
        //2. check char is tones?
        for char in chars {
            let charString = "\(char)"
            //2.1. char is in "zrsfxj"
            //2.2. char is in the map, e.g. ă ể ố
            if ("zrsfxj".contains(charString)) {
                tone = charString
            } else if
                let charBase = baseMap[charString],
                let charTone = toneMap[charString] {
                stem += charBase
                tone = charTone
            } else {
                stem += charString
            }
        }
        // Canonicalizing "y" and "i":
        // At the beginning of a word, use "y" if it's the only letter, or if it's followed by "e"
        // At other places, both "y" and "i" can occur after "a" or "u", but only "i" can occur after other letters
        let stemChars = stem.characters
        var formattedStem = ""
        for idx in stemChars.indices {
            let char = stemChars[idx]
            if ("yi".characters.contains(char)) {
                if (idx == stemChars.startIndex) {
                    if (stemChars.count == 1 || stemChars[stemChars.index(after: idx)] == "e" ) {
                        formattedStem += "y"
                    } else {
                        formattedStem += "i"
                    }
                } else {
                    let prevChar = stemChars[stemChars.index(before: idx)]
                    if ("au".characters.contains(prevChar)) {
                        formattedStem += "i"
                    }
                }
            } else {
                formattedStem += "\(char)"
            }
        }
        return formattedStem + tone
    }
    
    // Rules for placing the tone marker follows this page in Vietnamese Wikipedia:
    // Quy tắc đặt dấu thanh trong chữ quốc ngữ
    func display(_ string:String, as type: DisplayType) -> String {
        
        guard !string.isEmpty else { return string }
        
        let stem:String
        var tone:Character
        // Get tone
        if ("rsfxj".characters.contains(string.last!)) {
            stem = string.dropLast
            tone = string.last!
        } else {
            stem = string
            tone = "_"
        }
        
        
        // If any vowel carries quality marker, put tone marker there, too
        // In the combination "ươ", "ơ" gets the tone marker
        var p = stem.startIndex
        var newChars = ""
        while (p < stem.endIndex) {
            let p1 = stem.index(after: p)
            let p2 = stem.index(p, offsetBy: 2, limitedBy: stem.endIndex) ?? stem.endIndex
            let p4 = stem.index(p, offsetBy: 4, limitedBy: stem.endIndex) ?? stem.endIndex
            if stem.index(after: p) == stem.endIndex {
                newChars.append(stem[p])
                break
            }
            let key = stem[p..<p2]
            if combinedMap.keys.contains(key + "_") {
                
                if key == "dd" || (p4 < stem.endIndex && stem[p..<p4] == "uwow") {
                    newChars += combinedMap[key + "_"]!
                } else {
                    newChars += combinedMap[key + String(tone)]!
                    tone = "_"
                }
                p = p2
            } else {
                newChars.append(stem[p])
                p = p1
            }
        }
        if tone == "_" {
            return newChars
        }
        
        
        
        // Place tone marker
        // Find first and last vowel
        
        //fuck Swift string do not support iterating over indexes
        var firstVowel = newChars.startIndex
        while (firstVowel != newChars.endIndex &&
            !"aeiouy".characters.contains(newChars[firstVowel])) {
                firstVowel = newChars.index(after: firstVowel)
        }
        //a valid string shall have a vowel
        guard firstVowel != newChars.endIndex else { return string }
        
        var lastVowel = newChars.index(after: firstVowel)
        while (lastVowel != newChars.endIndex &&
            !"aeiouy".characters.contains(newChars[lastVowel])) {
                lastVowel = newChars.index(after: lastVowel)
        }
        
        let dist = newChars.distance(from: firstVowel, to: lastVowel)
        let betweenVowels = newChars[firstVowel..<lastVowel]
        if  dist == 3 ||
            (dist == 2 &&
                (lastVowel != newChars.endIndex ||
                    string.hasPrefix("gi") || string.hasPrefix("qu") ||
                    (type == .new && ["oa", "oe", "uy"].contains(betweenVowels))))
        {
            firstVowel = newChars.index(after: firstVowel)
        }
        //replace newChars[firstVowel] to the one in map
        return
            newChars.substring(to: firstVowel) +
                combinedMap[String(newChars[firstVowel]) + String(tone)]! +
                newChars.substring(from: newChars.index(after: firstVowel))
    }
    
    func display(_ rawString:String) -> String {
        return display(rawString, as: .new)
    }
    
    
    func getAllTones(_ string:String) -> [String] {
        let result = [string]
        //todo
        return result
    }
}

