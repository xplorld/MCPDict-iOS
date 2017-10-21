//
//  Orthography.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/30.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

protocol OrthographyImpl {
    associatedtype DisplayType
    func convert(_ string:String, to: DisplayType) -> String
    func display(_ s:String, as type: DisplayType) -> String
}

class Orthography {
    static let Unicode = UnicodeImpl()
    class UnicodeImpl {
        let firstHanzi = UInt32(0x4E00)
        let lastHanzi  = UInt32(0x9FA5)
        let variantsDict:[UInt32:[UInt32]]
        
        func isHanzi(codepoint: UInt32) -> Bool {
            return codepoint >= firstHanzi && codepoint <= lastHanzi
        }
        
        func getVariants(codepoint: UInt32) -> [UInt32] {
            return variantsDict[codepoint] ?? [codepoint]
        }
        
        fileprivate init() {
            variantsDict = Orthography.readVariants(filename: "orthography_hz_variants")
        }
        
    }
    
    static let MiddleChinese = MiddleChineseImpl()
    class MiddleChineseImpl {
        var mapInitials:[String:String] = [:] //声母
        var mapFinals:[String:String] = [:]   //韵母
        var mapTongx:[String:String] = [:]
        var mapHo:[String:String] = [:]
        var mapSjep:[String:String] = [:]
        var mapBiengSjyix:[String:String] = [:] //平水
        
        fileprivate init() {
            //initials
            for row in Orthography.readCSV(filename: "orthography_mc_initials", ofType: "tsv", length: 2) {
                if row[0] == "_" {
                    continue //no _
                }
                mapInitials[row[0]] = row[1]
            }
            
            //finals
            for row in Orthography.readCSV(filename: "orthography_mc_finals",ofType: "tsv",length: 5) {
                mapSjep[row[0]] = row[1]
                mapTongx[row[0]] = row[2]
                mapHo[row[0]] = row[3]
                mapFinals[row[0]] = row[4]
            }
            //平水
            //example: 下平15咸	咸銜嚴凡
            for row in Orthography.readCSV(filename: "orthography_mc_bieng_sjyix",ofType: "tsv",length: 2) {
                for char in row[1].characters {
                    mapBiengSjyix[String(char)] = row[0]
                }
            }
        }
    }
    
    static let Mandarin = MandarinImpl()
    struct MandarinImpl {
        enum DisplayType {
            case pinyin
            case bopomofo
        }
        var mapPinyin:[String:String] = [:]
        let vowels = "aoeiuvnm"
        ////todo: maybe later
        //let mapBopomofo:[String:String]
        fileprivate init() {
            for row in Orthography.readCSV(filename: "orthography_pu_pinyin",ofType: "tsv",length: 3) {
                let from = row[0]
                let to = row[1] + row[2]
                mapPinyin[from] = to
                mapPinyin[to] = from
            }
        }
        
        func display(_ rawString:String, as type: DisplayType = .pinyin) -> String {
            var raw = rawString
            //todo: now only pinyin -> display
            if type != .pinyin {
                fatalError("not implemented bopomofo display")
            }
            //raw: liu2
            if raw.isEmpty {
                return ""
            }
            let tone:Character
            
            if "1234".characters.contains(raw.last!) {
                tone = raw.remove(at: raw.index(before: raw.endIndex))
            } else {
                tone = "_"
            }
            
            //tone: 2 or _
            //raw:  liu
            
            var pos:String.Index! = nil
            //if "iu", pos = last char, aka "u"
            if raw.hasSuffix("iu") {
                pos = raw.index(before: raw.endIndex)
            } else {
                pos = vowels.characters.flatMap {
                    return raw.characters.index(of: $0)
                }.first
            }
            guard pos != nil else {return rawString} //fail, return unchanged
            
            //here: pos ok, tone ok
            var displayString = ""
            for index in raw.characters.indices {
                let charTone = index == pos ? tone : "_"
                let key = "\(raw[index])\(charTone)"
                let newValue = self.mapPinyin[key]
                if newValue != nil {
                    displayString.append(newValue!)
                } else {
                    displayString.append(raw[index])
                    if charTone != "_" {
                        displayString.append(self.mapPinyin["_\(tone)"]!)
                    }
                }
            }
            return displayString
        }
    }
    
    static let Japanese = JapaneseImpl()
    struct JapaneseImpl {
        enum DisplayType {
            case hiragana
            case katakana
            case nippon //database representation
            case hepburn
        }
        var maps:[DisplayType:[String:String]] = [
            .hiragana:[:],
            .katakana:[:],
            .nippon:[:],
            .hepburn:[:]
        ]
        fileprivate init() {
            //todo: read csv
            for row in Orthography.readCSV(filename: "orthography_jp", ofType: "tsv", length: 4) {
                for i in 0..<4 {
                    maps[.hiragana]![row[i]] = row[0]
                    maps[.katakana]![row[i]] = row[1]
                    maps[.nippon]![row[i]] = row[2]
                    maps[.hepburn]![row[i]] = row[3]
                }
            }
        }
        func convert(_ string:String, to: DisplayType) -> String {
            let map = self.maps[to]!
            var newString = ""
            var index = string.startIndex
            while index < string.endIndex {
                let prevIndex = index
                //for len in 4 ..> 0
                for len in (1..<5).reversed() {
                    if let advanced = string.index(index, offsetBy: len, limitedBy: string.endIndex),
                        let mapped = map[string.substring(with: index ..< advanced)]
                        {
                        newString.append(mapped)
                        index = advanced
                    }
                }
                //if no map match for len in 4 ..> 0
                //failed, return unchanged
                if prevIndex == index {
                    return string
                }
            }
            return newString
        }
        
        func display(_ s:String, as type: DisplayType = .hiragana) -> String {
            return convert(s, to: type)
        }
    }
    
    static let Korean = KoreanImpl()
    struct KoreanImpl {
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
        fileprivate init() {
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
    //todo: vietnamese
    //todo: cantonese display
    //todo: middlechinese detail
    static func readCSV(
        filename:String,
        ofType type:String = "tsv",
        length: Int = 2) -> [[String]] {
        do {
            
            let path = Bundle.main.path(forResource: filename, ofType: type)!
            let text = try String(contentsOfFile: path)
            
            var csvs:[[String]] = []
            
            let lines = text.components(separatedBy: CharacterSet.newlines)
            for line in lines {
                if line.isEmpty || line[line.startIndex] == "#" {
                    continue
                }
                let fields = line.components(separatedBy: CharacterSet.whitespaces)
                csvs.append(Array(fields.prefix(length)))
            }
            return csvs
        } catch {
            fatalError("exception on reading from tsv file!")
        }
    }
    
    static func readVariants(
        filename:String,
        ofType type:String = "txt") -> [UInt32: [UInt32]] {
        do {
            let path = Bundle.main.path(forResource: filename, ofType: type)!
            let text = try String(contentsOfFile: path)
            
            var dict:[UInt32: [UInt32]] = [:]
            
            let lines = text.components(separatedBy: CharacterSet.newlines)
            for line in lines {
                let codepoints = line
                    .unicodeScalars
                    .map { return $0.value }
                for codepoint in codepoints {
                    dict[codepoint] = codepoints
                }
            }
            return dict
        } catch {
            fatalError("exception on reading from tsv file!")
        }
    }
    
}
