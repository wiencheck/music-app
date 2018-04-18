//
//  FacesVC.swift
//  Plum
//
//  Created by Adam Wienconek on 11.04.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class FacesVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func changeNowPlayingScreen(identifier: String) {
        guard let tab = tabBarController as? PlumTabBarController else { return }
        tab.setIdentifier()
        tab.setPopupViewController()
        tab.updatePopup()
        tab.setPopup()
    }
    
    @IBAction func one() {
        GlobalSettings.changeNowPlaying(identifier: "eight")
        changeNowPlayingScreen(identifier: "eight")
    }
    
    @IBAction func two() {
        GlobalSettings.changeNowPlaying(identifier: "six")
        changeNowPlayingScreen(identifier: "six")
    }

}
