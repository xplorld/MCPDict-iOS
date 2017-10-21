//
//  Swift+Utils.swift
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

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            return Array(self[$0 ..< Swift.min($0 + chunkSize, self.count)]) // fixed
        }
    }
}
