//
//  OrthographyMandrin.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/22.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

struct OrthographyMandarin : OrthographyImpl {
    enum DisplayType {
        case pinyin
        case bopomofo
    }
    var mapPinyin:[String:String] = [:]
    let vowels = "aoeiuvnm"
    ////todo: maybe later
    //let mapBopomofo:[String:String]
    init() {
        for row in Orthography.readCSV(filename: "orthography_pu_pinyin",ofType: "tsv",length: 3) {
            let from = row[0]
            let to = row[1] + row[2]
            mapPinyin[from] = to
            mapPinyin[to] = from
        }
    }
    
    //O -> liu2
    func canonicalize(_ string: String) -> String {
        if (string.isEmpty) { return string; }
        //todo: if string in bopomofo
        
        //assume string is in pinyin, e.g. liú
        var resultString = ""
        var tone:Character = "_"
        for char in  string.characters {
            let key = String(char)
            if let value = mapPinyin[key] {
                //value: u2, a3, _4
                if let base = value.first,
                    base != "_" {
                    resultString.append(base)
                }
                tone = value.last!
            } else {
                resultString.append(char)
            }
        }
        if (tone != "_") {
            resultString.append(tone)
        }
        return resultString
    }
    
    
    //liu2 -> liú
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
            //first vowel in raw
            pos = vowels.characters
                .flatMap { return raw.characters.index(of: $0) }
                .first
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
    
    func display(_ rawString: String) -> String {
        return self.display(rawString, as: .pinyin)
    }
}
