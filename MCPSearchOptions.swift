//
//  MCPSearchOptions.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/10/21.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

struct MCPSearchOptions {
    var queryMode: MCPDictItemColumn = .unicode
    
    //searchInKuangxYonhOnly: if the queryed character does not have "mc" column
    //a.k.a. does not appear in kuangxYonh
    //filter it out
    var searchInKuangxYonhOnly: Bool = false
    
    //允许繁简转换
    var allowVariants: Bool = false
    
    //声调不敏感
    //对于每种语言有自己的处理方式
    var toneInsensitive: Bool = false
}
