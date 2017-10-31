//
//  OrthographyCantonese.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/31.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

class OrthographyCantonese: OrthographyImpl {
    
    enum DisplayType {
        case jyutping //database representation
        case cantonesePinyin
        case yale
        case sidneyLau
    }
    
    // References:
    // http://en.wikipedia.org/wiki/Jyutping
    // http://en.wikipedia.org/wiki/Cantonese_Pinyin
    // http://en.wikipedia.org/wiki/Yale_romanization_of_Cantonese
    // http://en.wikipedia.org/wiki/Sidney_Lau
    // http://humanum.arts.cuhk.edu.hk/Lexis/lexi-can/
    
    //fromType -> ToType -> FromValue -> ToValue
    var mapInitials : [DisplayType:[DisplayType:[String:String]]] = [:]
    var mapFinals   : [DisplayType:[DisplayType:[String:String]]] = [:]
    init() {
        let otherTypes:[DisplayType] = [.cantonesePinyin, .yale, .sidneyLau]
        mapInitials[.jyutping] = [:]
        mapFinals[.jyutping]   = [:]
        for otherType in otherTypes {
            mapInitials[.jyutping]![otherType] = [:]
            mapInitials[otherType] = [.jyutping:[:]]
            
            mapFinals[.jyutping]![otherType] = [:]
            mapFinals[otherType] = [.jyutping:[:]]
        }
        
        
        for row in Orthography.readCSV(filename: "orthography_ct_initials",ofType: "tsv",length: 4) {
            //#Jyutping, CantonesePinyin, Yale, SidneyLau
            mapInitials[.jyutping]![.cantonesePinyin]![row[0]] = row[1]
            mapInitials[.jyutping]![.yale]![row[0]]            = row[2]
            mapInitials[.jyutping]![.sidneyLau]![row[0]]       = row[3]
            
            mapInitials[.cantonesePinyin]![.jyutping]![row[1]] = row[0]
            mapInitials[.yale]![.jyutping]![row[2]]            = row[0]
            mapInitials[.sidneyLau]![.jyutping]![row[3]]       = row[0]
            
        }
        
        for row in Orthography.readCSV(filename: "orthography_ct_finals",ofType: "tsv",length: 4) {
            //#Jyutping, CantonesePinyin, Yale, SidneyLau
            mapFinals[.jyutping]![.cantonesePinyin]![row[0]] = row[1]
            mapFinals[.jyutping]![.yale]![row[0]]            = row[2]
            mapFinals[.jyutping]![.sidneyLau]![row[0]]       = row[3]
            
            mapFinals[.cantonesePinyin]![.jyutping]![row[1]] = row[0]
            mapFinals[.yale]![.jyutping]![row[2]]            = row[0]
            mapFinals[.sidneyLau]![.jyutping]![row[3]]       = row[0]
            
        }
    }

    func canonicalize(_ string: String) -> String {
        //todo: read from UserDefaults, and let user change in settings
        return canonicalize(string, from: .jyutping)
    }
    
    //anytype to jyutping
    func canonicalize(_ string: String, from type:DisplayType) -> String {
        guard !string.isEmpty && type != .jyutping else { return string }
        let mapInitials = self.mapInitials[type]![.jyutping]!
        let mapFinals   = self.mapFinals[type]![.jyutping]!
        
        let tone:String
        let stem:String
        if "123456789".characters.contains(string.last!) {
            // In Cantonese Pinyin, tones 7,8,9 are used for entering tones
            // They need to be replaced by with 1,3,6 in Jyutping
            switch (string.last!) {
            case "7": tone = "1"
            case "8": tone = "3"
            case "9": tone = "6"
            default: tone = String(string.last!)
            }
            stem = string.dropLast
        } else {
            tone = ""
            stem = string
        }
        
        //try to split stem as "\(initial)\(final)" and lookup to convert each
        let stemChars = stem.characters
        var maybeInitial:String?
        var maybeFinal:String?
        
        for initialLength in 0 ..< stemChars.count {
            let maybeOldInitial = stemChars.prefix(initialLength)
            let maybeOldFinal = stemChars.suffix( stemChars.count - initialLength )
            if  let theInitial = mapInitials[String(maybeOldInitial)],
                let theFinal = mapFinals[String(maybeOldFinal)] {
                maybeInitial = theInitial
                maybeFinal = theFinal
            }
        }
        //if no good split found for initial and final, return empty string
        guard maybeInitial != nil, maybeFinal != nil else {return "" }
        
        // In Yale, initial "y" is omitted if final begins with "yu"
        // If that happens, we need to put the initial "j" back in Jyutping
        let goodInitial:String
        let goodFinal = maybeFinal!
        if (type == .yale && maybeInitial!.isEmpty && maybeFinal!.hasPrefix("yu")) {
            goodInitial = "j"
        } else {
            goodInitial = maybeInitial!
        }
        
        return "\(goodInitial)\(goodFinal)\(tone)"
        
    }
    
    //jyutping to anytype
    func display(_ string:String, as type: DisplayType) -> String {
        guard !string.isEmpty && type != .jyutping else { return string }
        
        let mapInitials = self.mapInitials[.jyutping]![type]!
        let mapFinals   = self.mapFinals[.jyutping]![type]!
        
        var tone:String
        var stem:String
        if "123456".characters.contains(string.last!) {
            tone = String(string.last!)
            stem = string.dropLast
        } else {
            tone = ""
            stem = string
        }
        
        //try to split stem as "\(initial)\(final)" and lookup to convert each
        let stemChars = stem.characters
        var maybeInitial:String?
        var maybeFinal:String?
        
        for initialLength in 0 ..< stemChars.count {
            let maybeOldInitial = stemChars.prefix(initialLength)
            let maybeOldFinal = stemChars.suffix( stemChars.count - initialLength )
            if  let theInitial = mapInitials[String(maybeOldInitial)],
                let theFinal = mapFinals[String(maybeOldFinal)] {
                maybeInitial = theInitial
                maybeFinal = theFinal
            }
        }
        //if no good split found for initial and final, return empty string
        guard maybeInitial != nil, maybeFinal != nil else {return "" }
        
        // In Yale, initial "y" is omitted if final begins with "yu"
        // If that happens, we need to put the initial "j" back in Jyutping
        let goodInitial:String
        let goodFinal = maybeFinal!
        if (type == .yale && maybeInitial!.isEmpty && maybeFinal!.hasPrefix("yu")) {
            goodInitial = "j"
        } else {
            goodInitial = maybeInitial!
        }
        
        // In Cantonese Pinyin, tones 7,8,9 are used for entering tones
        // They need to be replaced from 1,3,6 in Jyutping
        if (type == .cantonesePinyin && "ptk".characters.contains(goodFinal.last!))
        {
            switch (tone) {
            case "1": tone = "7"
            case "3": tone = "8"
            case "6": tone = "9"
            default:  break
            }
        }
        
        return "\(goodInitial)\(goodFinal)\(tone)"
    }
    
    func getAllTones(_ string:String) -> [String] {
        var result = [string]
        guard !string.isEmpty else { return result }
        
        var tone:String
        var stem:String
        if "15678".characters.contains(string.last!) {
            tone = String(string.last!)
            stem = string.dropLast
        } else {
            tone = ""
            stem = string
        }
        guard !stem.isEmpty else { return result }
        //(7,8) is a group
        //(1,5,6) is a group
        //others do not change
        if stem.hasSuffix("h") {
            if (tone != "7") { result.append(stem + "7") }
            if (tone != "8") { result.append(stem + "8") }
        } else {
            if (tone != "1") { result.append(stem + "1") }
            if (tone != "5") { result.append(stem + "5") }
            if (tone != "6") { result.append(stem + "6") }
        }
        return result
    }
}
















