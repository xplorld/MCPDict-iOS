//
//  OrthographyMiddleChinese.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/22.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

// : OrthographyImpl
//todo: 比较难，等会再说
class OrthographyMiddleChinese : OrthographyInstance {
    
    var mapInitials:[String:String] = [:] //声母
    var mapFinals:[String:String] = [:]   //韵母
    var mapTongx:[String:String] = [:]
    var mapHo:[String:String] = [:]
    var mapSjep:[String:String] = [:]
    var mapBiengSjyix:[String:String] = [:] //平水
    
    func canonicalize(_ string: String) -> String {
        // Replace apostrophes with zeros to make SQLite FTS happy
        return string.replacingOccurrences(of: "0", with: "'")
    }
    func display(_ rawString: String) -> String {
        // Replace apostrophes with zeros to make SQLite FTS happy
        let trueString = rawString.replacingOccurrences(of: "'", with: "0")
        return "\(trueString) （\(detail(trueString))）"
    }
    
    func detail(_ rawString: String) -> String {
        guard let lastChar = rawString.last else { return "" }
        let tone:Int
        let stem:String
        switch lastChar {
        case "x":
            tone = 1
            stem = rawString.dropLast
        case "h":
            tone = 2
            stem = rawString.dropLast
        case "d":
            tone = 2
            stem = rawString
        case "p":
            tone = 3
            stem = rawString.dropLast + "m"
        case "t":
            tone = 3
            stem = rawString.dropLast + "n"
        case "k":
            tone = 3
            stem = rawString.dropLast + "ng"
        default:
            tone = 0
            stem = rawString
        }
        
        var beginStr = ""
        var finalStr = ""
        var extraJ = false
        let apostrophes = stem.index(of: "'")
        if let apostrophes = apostrophes {
            beginStr = stem.substring(to: apostrophes)
            finalStr = stem.substring(from: stem.index(after: apostrophes))
            if beginStr == "i" {
                beginStr = ""
            }
            guard
                mapInitials.keys.contains(beginStr),
                mapFinals.keys.contains(finalStr) else {return ""}
        } else {
            //no apostrophes
            for i in (0...3).reversed() {
                if i >= stem.count {
                    continue
                }
                let index_i = stem.index(stem.startIndex, offsetBy: i)
                let first_i_substring = stem.substring(to: index_i)
                
                if mapInitials.keys.contains(first_i_substring) {
                    beginStr = first_i_substring
                    finalStr = stem.substring(from: index_i)
                    break
                }
            }
            if finalStr.isEmpty {
                return ""
            }
            
            // Extract extra "j" in syllables that look like 重紐A類
            if finalStr.first == "j" {
                if finalStr.count < 2 {
                    return ""
                }
                extraJ = true
                let index_at_1 = finalStr.index(after: finalStr.startIndex)
                let char_at_1 = finalStr[index_at_1]
                if ["i", "y"].contains(char_at_1) {
                    finalStr = finalStr.substring(from: index_at_1)
                } else {
                    finalStr = "i" + finalStr.substring(from: index_at_1)
                }
            }
            
            // Recover omitted glide in final
            if beginStr.last == "r" { // 只能拼二等或三等韻，二等韻省略介音r
                if !["i", "y"].contains(finalStr.first!) {
                    finalStr = "r" + finalStr
                }
            }
            else if beginStr.last == "j" { // 只能拼三等韻，省略介音i
                if !["i", "y"].contains(finalStr.first!) {
                    finalStr = "i" + finalStr
                }
            }
        }
        guard mapFinals.keys.contains(finalStr) else {return ""}
        
        // Distinguish 重韻
        if (finalStr == "ia") { // 牙音声母爲戈韻，其餘爲麻韻
            if ["k", "kh", "g", "ng"].contains(beginStr) {
                finalStr = "Ia"
            }
        }
        else if finalStr == "ieng" || finalStr == "yeng" {
            // 脣牙喉音声母直接接-ieng,-yeng者及莊組爲庚韻，其餘爲清韻
            if ["p", "ph", "b", "m",
                "k", "kh", "g", "ng",
                "h", "gh", "q", "",
                "cr", "chr", "zr", "sr", "zsr"].contains(beginStr) && !extraJ {
                finalStr = finalStr == "ieng" ? "Ieng" : "Yeng"
            }
        }
        else if finalStr == "in" {    // 莊組声母爲臻韻，其餘爲眞韻
            if ["cr", "chr", "zr", "sr", "zsr"].contains(beginStr) {
                finalStr = "In"
            }
        }
        else if finalStr == "yn" { // 脣牙喉音声母直接接-yn者爲眞韻，其餘爲諄韻
            if ["p", "ph", "b", "m",
                "k", "kh", "g", "ng",
                "h", "gh", "q", ""].contains(beginStr) && !extraJ {
                finalStr = "Yn"
            }
        }
        // Resolve 重紐
        var dryungNriux = ""
        if let c = mapFinals[finalStr]?.first,
        "支脂祭眞仙宵侵鹽".contains(c),
            ["p", "ph", "b", "m",
             "k", "kh", "g", "ng",
             "h", "gh", "q", "", "j"].contains(beginStr) {
            dryungNriux = (extraJ || beginStr == "j") ? "A" : "B"
        }
        let mux = mapInitials[beginStr]!
        let sjep = mapSjep[finalStr]!
        
        let finalMapped = mapFinals[finalStr]!
        let index = finalMapped.index(finalMapped.startIndex, offsetBy: finalStr.last == "d" ? 0 : tone)
        let yonh = String(finalMapped[index])
        
        let tongx = mapTongx[finalStr]!
        let ho = mapHo[finalStr]!
        let biengSjyix = mapBiengSjyix[yonh]!
        return mux + sjep + yonh + dryungNriux + tongx + ho + " " + biengSjyix
    }
    
    
    init() {
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
            for char in row[1] {
                mapBiengSjyix[String(char)] = row[0]
            }
        }
    }
    
    
}
