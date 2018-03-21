//
//  MPMediaItem.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

private var xoAssociationKey: UInt8 = 0
private var boAssociationKey: Bool = false

extension MPMediaItem {
    var index: Int! {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? Int
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func labelFromRating() -> String {
        switch self.rating{
        case 1:
            return "★☆☆☆☆"
        case 2:
            return "★★☆☆☆"
        case 3:
            return "★★★☆☆"
        case 4:
            return "★★★★☆"
        case 5:
            return "★★★★★"
        default:
            return "☆☆☆☆☆"
        }
    }
}
