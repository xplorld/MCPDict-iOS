//
//  String+Utils.swift
//  HanziVoice
//
//  Created by Xplorld on 2017/7/30.
//  Copyright © 2017年 Xplorld. All rights reserved.
//

import UIKit

extension String {
    var first:Character? {
        if self.isEmpty {
            return nil
        }
        return self[self.startIndex]
    }
    var last:Character? {
        if self.isEmpty {
            return nil
        }
        let index = self.index(before: self.endIndex)
        return self[index]
    }
}
