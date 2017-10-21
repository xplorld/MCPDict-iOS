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
    
    static func voiceTypes() -> [MCPDictItemColumn] {
        return [.middleChinese,.mandrin,.cantonese,.wu,.min,.korean,.vietnamese,.jp_go,.jp_kan,.jp_tou,.jp_kwan,jp_other]
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
    
    func search(keyword:String, options:MCPSearchOptions) -> [MCPChar] {
        let codepoints =
            keyword
                .unicodeScalars
                .map { return String($0.value, radix:16).uppercased() }
        
        var query = mcpdict.filter(codepoints.contains(MCPDictItemColumn.unicode.expression))
        if options.searchInKuangxYonhOnly {
            let mc = MCPDictItemColumn.middleChinese.expression
            //if write as `mc != nil`, the swift compiler will complain that mc can never be nil
            //reverse the operands to cheat
            query = query.filter( nil != mc)
        }
        do {
            return try self.db.prepare(query).flatMap(MCPChar.init)
        }
        catch {
            print("some exceptions!")
            return []
        }
    }
}
