//
//  UIStatusBarStyle.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

extension UIStatusBarStyle {
    var style: UIStatusBarStyle {
        get{
          return UIApplication.shared.statusBarStyle
        } set {
            UIApplication.shared.statusBarStyle = newValue
        }
    }
    static var themed = UIStatusBarStyle.default
}
