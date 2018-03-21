//
//  UIViewController.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

extension UIViewController {
    func updatePrompt(version: Float) {
        let alert = ColoredAlertController(title: "This feature requires iOS \(version) or later", message: "To use it, you will have to update your firmware", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
}
