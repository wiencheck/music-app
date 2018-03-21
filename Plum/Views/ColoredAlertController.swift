//
//  ColoredAlertController.swift
//  Plum
//
//  Created by Adam Wienconek on 09.02.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class ColoredAlertController: UIAlertController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.tintColor = GlobalSettings.tint.color
    }
    
    init(color: UIColor) {
        super.init()
        self.view.tintColor = color
    }

}
