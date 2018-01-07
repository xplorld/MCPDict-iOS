//
//  MCPDictItemColumn.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/31.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import Foundation
import SQLite

enum MCPDictItemColumn : String {
    case unicode = "unicode"
    case middleChinese = "mc"
    case mandrin = "pu"
    case cantonese = "ct"
    case wu = "sh"
    case min = "mn"
    case korean = "kr"
    case vietnamese = "vn"
    case jp_go = "jp_go"
    case jp_kan = "jp_kan"
    case jp_tou = "jp_tou"
    case jp_kwan = "jp_kwan"
    case jp_other = "jp_other"
    
    var expression : Expression<String?> {
        return Expression<String?>(self.rawValue)
    }
    
    var displayName : String {
        return [
            .unicode: "汉字",
            .middleChinese: "广韵中古音",
            .mandrin: "普通话拼音",
            .cantonese: "广东话拼音",
            .wu: "吴语音",
            .min: "闽语音",
            .korean: "韩文",
            .vietnamese: "越南文",
            .jp_go: "日语吴音",
            .jp_kan: "日语汉音",
            .jp_tou: "日语唐音",
            .jp_kwan: "日语惯用音",
            .jp_other: "日语其他音",
            ][self]!
    }
    
    static func queryTypes() -> [MCPDictItemColumn] {
        return [.unicode, .middleChinese,.mandrin,.cantonese,.wu,.min,.korean,.vietnamese,.jp_go,.jp_kan] /* jp_any */
    }
    
    static func voiceTypes() -> [MCPDictItemColumn] {
        return [.middleChinese,.mandrin,.cantonese,.wu,.min,.korean,.vietnamese,.jp_go,.jp_kan,.jp_tou,.jp_kwan,jp_other]
    }
    
    func orthography() -> OrthographyInstance {
        switch self {
        case .unicode:
            return Orthography.Unicode
        case .middleChinese:
            return Orthography.MiddleChinese
        case .mandrin:
            return Orthography.Mandarin
        case .cantonese:
            return Orthography.Cantonese
        case .wu:
            return Orthography.Wu
        case .min:
            return Orthography.Min
        case .korean:
            return Orthography.Korean
        case .vietnamese:
            return Orthography.Vietnamese
        case .jp_go, .jp_kan, .jp_tou, .jp_kwan, .jp_other:
            return Orthography.Japanese
        }
        //assigned for every case, no need to default
    }
    
    func splitForSearch(_ string: String, options: MCPSearchOptions) -> [String]
    {
        return self.orthography().splitForSearch(string, options: options)
    }
    
    func canonicalize(_ string: String) -> String {
        return self.orthography().canonicalize(string)
    }
    
    func display(_ string:String) -> String {
        return self.orthography().display(string)
    }
    
    func displayAll(_ string:String) -> String {
        var newString = ""
        let alphanumerics = CharacterSet.alphanumerics
        let scalars = string.unicodeScalars
        
        let index = scalars.startIndex
        var beginIndex = index
        var endIndex = index
        while (beginIndex < scalars.endIndex) {
            endIndex = beginIndex
            while endIndex < scalars.endIndex && alphanumerics.contains(scalars[endIndex]) {
                endIndex = scalars.index(after: endIndex) //increment if ok
            }
            //here: scalars[endIndex] is not an alphanumerics
            //if end>begin: a good range
            if endIndex > beginIndex {
                let substring = String(scalars[beginIndex ..< endIndex])
                let displayed = self.display(substring)
                newString.append(displayed)
                beginIndex = endIndex
            }
            while beginIndex < scalars.endIndex && !alphanumerics.contains(scalars[beginIndex]) {
                beginIndex = scalars.index(after: beginIndex) //increment if ok
            }
            let substring = String(scalars[endIndex ..< beginIndex])
            newString.append(substring)
        }
        newString = newString
            .replacingOccurrences(of: ",", with: ", ")
            .replacingOccurrences(of: "(", with: " (")
            .replacingOccurrences(of: "]", with: "] ")
            .replacingOccurrences(of: " +", with: " ")
            .replacingOccurrences(of: " ,", with: ",")
        return newString
        
    }
    
}
