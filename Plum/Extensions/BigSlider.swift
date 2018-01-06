//
//  BigSlider.swift
//  Plum
//
//  Created by Adam Wienconek on 06.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import CoreGraphics

class BigSlider: UISlider {
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = CGRect(x: 0, y: -17, width: 35, height: 35)
        return rect
        //return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], -10 , -10)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
