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
class OrthographyMiddleChinese : OrthographyImpl {

    var mapInitials:[String:String] = [:] //声母
    var mapFinals:[String:String] = [:]   //韵母
    var mapTongx:[String:String] = [:]
    var mapHo:[String:String] = [:]
    var mapSjep:[String:String] = [:]
    var mapBiengSjyix:[String:String] = [:] //平水
    
    enum DisplayType {
        case normal
    }
    
    //todo
    func display(_ rawString: String, as type: DisplayType) -> String {
        return rawString
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
            for char in row[1].characters {
                mapBiengSjyix[String(char)] = row[0]
            }
        }
    }
    
    
}
