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
    
    func instruct(_ key: String, message: String, completion: (() -> Void)?) {
        if !UserDefaults.standard.bool(forKey: key) {
            let a = ColoredAlertController(title: "Pro tip", message: message, preferredStyle: .alert)
            let got = UIAlertAction(title: "Got it", style: .default, handler: { _ in
                UserDefaults.standard.set(true, forKey: key)
            })
            let remind = UIAlertAction(title: "Remind me", style: .default, handler: { _ in
                UserDefaults.standard.set(false, forKey: key)
            })
            a.addAction(got)
            a.addAction(remind)
            present(a, animated: true, completion: completion)
        }
    }
}
