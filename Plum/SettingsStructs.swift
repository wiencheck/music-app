//
//  SettingsStructs.swift
//  wiencheck
//
//  Created by Adam Wienconek on 27.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

struct UpNextSettings {
    var alwaysLight = false
    var alwaysBlack = false
    var adaptiveTableView = false
    var upperBarColored = false
}

struct GlobalSettings{
    static let defaults = UserDefaults.standard
    static var ratingMode = false
    static func changeRatingMode(_ t: Bool){
        self.ratingMode = t
        RemoteCommandManager.shared.switchRatingCommands(t)
        print("Rating mode is \(ratingMode)")
        defaults.set(t, forKey: "ratingMode")
    }
    
    static var theme = UIColor.appleRed
    static func changeTheme(_ t: UIColor){
        self.theme = t
    }
    
    static var alphabeticalSort = false
    static func changeAlphabeticalSort(_ t: Bool){
        self.alphabeticalSort = t
    }
    
    static var indexVisible = false
    static func changeIndexVisibility(_ t: Bool) {
        self.indexVisible = t
        defaults.set(t, forKey: "indexVisible")
    }
}
