//
//  myVolumeSlider.swift
//  wiencheck
//
//  Created by Adam Wienconek on 07.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import MediaPlayer
import UIKit

@IBDesignable
class VolumeSlider: MPVolumeView{
    @IBInspectable var thumbImg: UIImage?{
        didSet{
            self.setVolumeThumbImage(thumbImg, for: .normal)
        }
    }
    
    @IBInspectable var minSlider: UIImage?{
        didSet{
            self.setMinimumVolumeSliderImage(minSlider, for: .normal)
        }
    }
    
    @IBInspectable var maxSlider: UIImage?{
        didSet{
            self.setMaximumVolumeSliderImage(maxSlider, for: .normal)
        }
    }
}
