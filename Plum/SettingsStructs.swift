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
    static var remote: RemoteCommandManager!
    static let defaults = UserDefaults.standard
    static var ratingMode = false
    static var bottomInset: CGFloat!
    static func changeRatingMode(_ t: Bool){
        self.ratingMode = t
        self.remote.switchRatingCommands(t)
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
    enum styles {
        case modern
        case classic
    }
    static var popupStyle: styles = .classic
    static func changePopupStyle(_ t: styles) {
        self.popupStyle = t
        if t == .classic {
            self.bottomInset = 40.0
            defaults.set(false, forKey: "modernPopup")
        }else {
            self.bottomInset = 64.0
            defaults.set(true, forKey: "modernPopup")
        }
    }
    static func changeFeedbackContent(which: String, message: String, value: Int) {
        switch which {
        case "Like":
            remote.feedbacks["Like"] = Feedback(message, value)
            //remote.toggleLikeCommand(self.ratingMode)
            defaults.set(message, forKey: "likeMessage")
            defaults.set(value, forKey: "likeValue")
        case "Dislike":
            remote.feedbacks["Dislike"] = Feedback(message, value)
            //remote.toggleDislikeCommand(self.ratingMode)
            defaults.set(message, forKey: "dislikeMessage")
            defaults.set(value, forKey: "dislikeValue")
        case "Bookmark":
            remote.feedbacks["Bookmark"] = Feedback(message, value)
            //remote.toggleBookmarkCommand(self.ratingMode)
            defaults.set(message, forKey: "bookmarkMessage")
            defaults.set(value, forKey: "bookmarkValue")
        default:
            print("Zla nazwa feedbacku")
        }
        remote.switchRatingCommands(self.ratingMode)
    }
}
