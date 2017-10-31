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
    var dropLast:String {
        if self.isEmpty {
            return self
        }
        //opened range
        return self.substring(to: self.index(before: self.endIndex))
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            return Array(self[$0 ..< Swift.min($0 + chunkSize, self.count)]) // fixed
        }
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}

extension Collection {
    func endoFlatMap_if(
        _ condition: Bool,
        _ transform: ((Self.Iterator.Element) -> [Self.Iterator.Element]))
        -> [Self.Iterator.Element] {
            if (condition) {
                return self.flatMap(transform)
            } else {
                return Array(self)
            }
    }
}

//extension AnyObject {
import SQLite
extension QueryType {
    func endoTransform_if(
        _ condition: Bool,
        _ transform:((Self) -> Self))
    -> Self {
        if (condition) {
            return transform(self)
        } else {
            return self
        }
    }
}
