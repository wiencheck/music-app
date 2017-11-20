//
//  trackSlider.swift
//  wiencheck
//
//  Created by Adam Wienconek on 28.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

@IBDesignable
class trackSlider: UISlider {
    
    @IBInspectable var thumbImg: UIImage?{
        didSet{
            setThumbImage(thumbImg, for: .normal)
        }
    }
    
    @IBInspectable var minTrackImg: UIImage?{
        didSet{
            setMinimumTrackImage(minTrackImg, for: .normal)
        }
    }
    
    @IBInspectable var maxTrackImg: UIImage?{
        didSet{
            setMaximumTrackImage(maxTrackImg, for: .normal)
        }
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    

}
