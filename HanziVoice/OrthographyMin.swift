//
//  OrthographyWu.swift
//  
//
//  Created by Xplorld on 2017/11/1.
//
//

import UIKit

//do not have displayType, not comform to OrthographyImpl
class OrthographyMin: OrthographyInstance {
    func getAllTones(_ string:String) -> [String] {
        var result = [string]
        guard !string.isEmpty else { return result }
        
        var tone:String
        var stem:String
        if "1234578".characters.contains(string.last!) {
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
        if "ptkh".characters.contains(stem.last!) {
            if (tone != "4") { result.append(stem + "4") }
            if (tone != "8") { result.append(stem + "8") }
        } else {
            if (tone != "1") { result.append(stem + "1") }
            if (tone != "2") { result.append(stem + "2") }
            if (tone != "3") { result.append(stem + "3") }
            if (tone != "5") { result.append(stem + "5") }
            if (tone != "7") { result.append(stem + "7") }
        }
        return result
    }
    
}
