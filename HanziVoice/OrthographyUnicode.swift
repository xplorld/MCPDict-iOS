//
//  OrthographyUnicode.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/22.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

class OrthographyUnicode : OrthographyImpl {
    
    let firstHanzi = UInt32(0x4E00)
    let lastHanzi  = UInt32(0x9FA5)
    let variantsDict:[UInt32:[UInt32]]
    
    enum DisplayType {
        case unicode
    }
    
    func display(_ rawString: String, as type: DisplayType) -> String {
        return rawString
    }
    
    func isHanzi(codepoint: UInt32) -> Bool {
        return codepoint >= firstHanzi && codepoint <= lastHanzi
    }
    
    func getVariants(codepoint: UInt32) -> [UInt32] {
        return variantsDict[codepoint] ?? [codepoint]
    }
    
    init() {
        variantsDict = Orthography.readVariants(filename: "orthography_hz_variants")
    }
    
}
