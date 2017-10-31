//
//  OrthographyUnicode.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/22.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit
import Swift

class OrthographyUnicode : OrthographyImpl {
    
    let firstHanzi = UInt32(0x4E00)
    let lastHanzi  = UInt32(0x9FA5)
    let variantsDict:[UInt32:[UInt32]]
    
    enum DisplayType {
        case unicode
    }
    
    func display(_ rawString: String) -> String {
        return display(rawString, as: .unicode)
    }
    
    func display(_ rawString: String, as type: DisplayType = .unicode) -> String {
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
    
    func splitForSearch(_ string: String, options: MCPSearchOptions) -> [String] {
        return string
            .unicodeScalars      //[UnicodeScalar]
            .map { return $0.value } //[UInt32]
            .filter { return Orthography.Unicode.isHanzi(codepoint: $0) }
            .endoFlatMap_if(options.allowVariants)
                { return Orthography.Unicode.getVariants(codepoint: $0) }
            .map { return String($0, radix:16).uppercased() }
    }
}
