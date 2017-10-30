//
//  Orthography.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/30.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

protocol OrthographyImpl {
    associatedtype DisplayType
    func display(_ rawString:String, as type: DisplayType) -> String
}

extension OrthographyImpl {
    func canonicalize(_ string:String) -> String {
        return string
    }
    
    //by default, split by space and comma
    func splitForSearch(_ string:String, options: MCPSearchOptions) -> [String] {
        return string
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .flatMap { return $0.components(separatedBy: ",") }
    }
    
}

class Orthography {
    
    static let Unicode = OrthographyUnicode()
    
    //todo
    static let MiddleChinese = OrthographyMiddleChinese()
    
    //todo: no bopomofo yet
    static let Mandarin = OrthographyMandarin()

    static let Japanese = OrthographyJapanese()
    
    static let Korean = OrthographyKorean()
}

extension Orthography {
    //todo: vietnamese
    //todo: cantonese display
    //todo: middlechinese detail
    static func readCSV(
        filename:String,
        ofType type:String = "tsv",
        length: Int = 2) -> [[String]] {
        do {
            
            let path = Bundle.main.path(forResource: filename, ofType: type)!
            let text = try String(contentsOfFile: path)
            
            var csvs:[[String]] = []
            
            let lines = text.components(separatedBy: CharacterSet.newlines)
            for line in lines {
                if line.isEmpty || line[line.startIndex] == "#" {
                    continue
                }
                let fields = line.components(separatedBy: CharacterSet.whitespaces)
                csvs.append(Array(fields.prefix(length)))
            }
            return csvs
        } catch {
            fatalError("exception on reading from tsv file!")
        }
    }
    
    static func readVariants(
        filename:String,
        ofType type:String = "txt") -> [UInt32: [UInt32]] {
        do {
            let path = Bundle.main.path(forResource: filename, ofType: type)!
            let text = try String(contentsOfFile: path)
            
            var dict:[UInt32: [UInt32]] = [:]
            
            let lines = text.components(separatedBy: CharacterSet.newlines)
            for line in lines {
                let codepoints = line
                    .unicodeScalars
                    .map { return $0.value }
                for codepoint in codepoints {
                    dict[codepoint] = codepoints
                }
            }
            return dict
        } catch {
            fatalError("exception on reading from tsv file!")
        }
    }
    
}
