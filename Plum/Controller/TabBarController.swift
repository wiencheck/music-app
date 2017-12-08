//
//  TabBarController.swift
//  Plum
//
//  Created by Adam Wienconek on 08.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var nowPlaying: EightNowPlayingVC!
    let player = Plum.shared
    var timer: Timer!
    var playbackBtn: UIBarButtonItem!
    var nextBtn: UIBarButtonItem!
    var elapsed: Float!
    var duration: Float!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
