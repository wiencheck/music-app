//
//  UtilityFunctions.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation

public func calculateCollectionViewCellSize(itemsPerRow: Int, frame: CGRect, device: String) -> CGSize{
    switch itemsPerRow {
    case 2:
        let height = frame.height
        let width = frame.width
        let Waspect: CGFloat = 0.45
        var Haspect: CGFloat = 0.35
        if device == "iPhone X" {
            Haspect = 0.27
        }
        return CGSize(width: width*Waspect, height: height*Haspect)
    case 3:
        let height = frame.height
        let width = frame.width
        let Waspect: CGFloat = 0.29
        var Haspect: CGFloat = 0.22
        if device == "iPhone X" {
            Haspect = 0.18
        }
        return CGSize(width: width*Waspect, height: height*Haspect)
    default:
        return CGSize()
    }
}


