//
//  BlurView.swift
//  Plum
//
//  Created by Adam Wienconek on 13.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable class BlurView : UIView {
    // Use the following property to set the tintColor. Set it to nil to reset.
    @IBInspectable var blurTintColor: UIColor! {
        set {
            toolbar.barTintColor = blurTintColor
        }
        get {
            return toolbar.barTintColor
        }
    }
    lazy var toolbar:UIToolbar = {
        // If we don't clip to bounds the toolbar draws a thin shadow on top
        self.clipsToBounds = true
        
        let toolbar = UIToolbar(frame: self.bounds)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(toolbar, at: 0)
        let views = ["toolbar": toolbar]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toolbar]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[toolbar]|", options: [], metrics: nil, views: views))
        
        return toolbar
    }()
}
