//
//  DBReader.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/29.
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
    
    func splitForSearch(_ string: String, options: MCPSearchOptions) -> [String]
    {
        switch self {
        case .unicode:
            return Orthography.Unicode.splitForSearch(string, options: options)
        case .korean:
            return Orthography.Korean.splitForSearch(string, options: options)
        case .jp_go, .jp_kan, .jp_tou, .jp_kwan, .jp_other:
            return Orthography.Japanese.splitForSearch(string, options: options)
        //todo: more dispatches
        default:
            return string.components(separatedBy: .whitespacesAndNewlines)
        }
    }
    
    func canonicalize(_ string: String) -> String {
        switch self {
        case .mandrin:
            return Orthography.Mandarin.canonicalize(string)
        case .korean:
            return Orthography.Korean.canonicalize(string)
        case .jp_go, .jp_kan, .jp_tou, .jp_kwan, .jp_other:
            return Orthography.Japanese.canonicalize(string)
        //todo: more dispatches
        default:
            return string
        }
    }
    
    func display(_ string:String) -> String {
        switch self {
        case .mandrin:
            return Orthography.Mandarin.display(string)
        case .korean:
            return Orthography.Korean.display(string)
        case .jp_go, .jp_kan, .jp_tou, .jp_kwan, .jp_other:
            return Orthography.Japanese.display(string)
        //todo: more dispatches
        default:
            return string
        }
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

struct MCPVoice {
    let raw:String
    let display:String
    let type:MCPDictItemColumn
    
    //todo:parse
    //todo: orthography applies here
    init(raw: String, type:MCPDictItemColumn) {
        self.raw = raw
        self.type = type
        self.display = type.displayAll(raw)
    }
    
    //some disgusting inconsistency in iOS string related APIs
    //We use String / String.Index / CharacterView for indexing and subscribing
    //no easy way to convert String.Index to/from Int
    //but if NSAttributedString is involved, things become nasty
    //have to convert String.Index to Int to make NSRange's
    //have to use String.characters.count as index,
    //which is strongly discouraged by Apple
    //sigh
    func formatted() -> NSAttributedString {
        let plain:NSMutableString = ""
        //have to manually manage a `count' instead of plain.characters.count
        //since plain.characters.count *seems to* be O(*n*)
        //what is Apple even thinking? How hard/costy is it to maintain a `count'?
        var bolds:[Int] = []
        var dims :[Int] = []
        
        for char in self.display.characters {
            switch char {
            case "*":
                bolds.append(plain.length)
            case "|":
                dims.append(plain.length)
            default:
                plain.append(String(char))
            }
        }
        let fontSize:CGFloat = 16 //magic...
        let normalFont = UIFont.systemFont(ofSize: fontSize)
        let boldFont = UIFont.boldSystemFont(ofSize: fontSize)
        let dimColor = UIColor.darkGray
        let attributed = NSMutableAttributedString(string: plain as String)
        attributed.beginEditing()
        
        attributed.addAttribute(NSFontAttributeName, value: normalFont, range: NSMakeRange(0, attributed.length))
        
        for pair in bolds.chunked(by: 2) {
            attributed.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(pair[0], pair[1] - pair[0]))
        }
        
        for pair in dims.chunked(by: 2) {
            attributed.addAttribute(NSForegroundColorAttributeName, value: dimColor, range: NSMakeRange(pair[0], pair[1] - pair[0]))
        }
        
        attributed.endEditing()
        
        return attributed
    }
}

class MCPChar {
    let voices:[MCPVoice]
    let unicode:String
    let value:String
    init?(_ row: Row) {
        guard
            let unicode = row[MCPDictItemColumn.unicode.expression],
            let unicodeInt = UInt32(unicode, radix: 16),
            let scalar = UnicodeScalar(unicodeInt)
            else {return nil}
        
        self.unicode = unicode
        self.value = String(scalar)
        self.voices = MCPDictItemColumn
            .voiceTypes()
            .flatMap {
                guard let rawVoice = row[$0.expression]
                    else {return nil}
                return MCPVoice(raw: rawVoice, type: $0)
        }
    }
}

class MCPDictDB {
    //would always succeed 'cause we sure the file is there
    let db:Connection
    let mcpdict = Table("mcpdict")
    
    init() {
        let path = Bundle.main.path(forResource: "mcpdict", ofType: "db")!
        self.db = try! Connection(path, readonly: true)
    }
    
    func constructQuery(keyword:String, options:MCPSearchOptions) -> QueryType {
        var query:QueryType
        
        let queryMode = options.queryMode
        
        return mcpdict.filter(
            queryMode
                .splitForSearch(keyword, options: options)
                .contains(queryMode.expression)
        )
        
        //todo implement splitForSearch for mc
            let canonicalized = queryMode.canonicalize(keyword)
            query = mcpdict.filter(MCPDictItemColumn.mandrin.expression == canonicalized)
        
    
        if options.searchInKuangxYonhOnly {
            let mc = MCPDictItemColumn.middleChinese.expression
            //if write as `mc != nil`, the swift compiler will complain that mc can never be nil
            //reverse the operands to cheat
            query = query.filter( nil != mc)
        }
        
        return query
    }
    
    func search(keyword:String, options:MCPSearchOptions) -> [MCPChar] {
        
        let query = constructQuery(keyword: keyword, options: options)
        
        do {
            return try self.db.prepare(query).flatMap(MCPChar.init)
        }
        catch {
            print("some exceptions!")
            return []
        }
    }
}
