//
//  OrthographyJapanese.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/22.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

struct OrthographyJapanese : OrthographyImpl {
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
    init() {
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
    
    func canonicalize(_ string: String) -> String {
        return convert(string, to: .nippon)
    }
}
    
