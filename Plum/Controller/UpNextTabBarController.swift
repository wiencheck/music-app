//
//  UpNextTabBarController.swift
//  Plum
//
//  Created by Adam Wienconek on 10.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class UpNextTabBarController: UITabBarController, UITabBarControllerDelegate {

    var upDelegate: UpNextDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
        upDelegate?.backFromUpNext()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let _ = viewController as? DummyVC {
            finish()
            return false
        }else{
            return true
        }
    }

}
