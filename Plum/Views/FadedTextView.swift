//
//  FadedTextView.swift
//  Plum
//
//  Created by Adam Wienconek on 11.04.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class FadedTextView: UITextView {

    let fadePercentage: Double = 0.05
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor
        
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        gradientLayer.colors = [transparent, opaque, opaque, transparent]
        gradientLayer.locations = [0, NSNumber(value: fadePercentage), NSNumber(value: 1 - fadePercentage), 1]
        
        maskLayer.addSublayer(gradientLayer)
        self.layer.mask = maskLayer
        
    }

}
