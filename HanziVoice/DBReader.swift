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
    
    func expression() -> Expression<String?> {
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
    
    //todo: bold, grey, etc
    func formatted() -> NSAttributedString {
        return NSAttributedString(string: display)
    }
}

class MCPChar {
    let voices:[MCPVoice]
    let unicode:String
    let value:String
    init?(_ row: Row) {
        guard
            let unicode = row[MCPDictItemColumn.unicode.expression()],
            let unicodeInt = UInt32(unicode, radix: 16),
            let scalar = UnicodeScalar(unicodeInt)
            else {return nil}
        
        self.unicode = unicode
        self.value = String(scalar)
        self.voices = MCPDictItemColumn
            .voiceTypes()
            .flatMap {
                guard let rawVoice = row[$0.expression()]
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
    
    func search(_ keyword:String) -> [MCPChar] {
        let codepoints =
            keyword
                .unicodeScalars
                .map { return String($0.value, radix:16).uppercased() }
        
        let query = mcpdict.filter(codepoints.contains(MCPDictItemColumn.unicode.expression()))
        
        do {
            return try self.db.prepare(query).flatMap(MCPChar.init)
        }
        catch {
            print("some exceptions!")
            return []
        }
    }
}
