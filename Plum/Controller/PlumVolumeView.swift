//
//  PlumVolumeView.swift
//  Plum
//
//  Created by Adam Wienconek on 10.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class PlumVolumeView: MPVolumeView {
    
    override func volumeThumbRect(forBounds bounds: CGRect, volumeSliderRect rect: CGRect, value: Float) -> CGRect {
        return CGRect(x: 0, y: 0, width: 2, height: 2)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
