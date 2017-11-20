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

enum styles {
    case modern
    case classic
}

enum Theme: String {
    case light = "light"
    case dark = "dark"
    case adaptive = "adaptive"
}

struct GlobalSettings{
    static var remote: RemoteCommandManager!
    static let defaults = UserDefaults.standard
    static var ratingMode = false
    static var full = false
    static var bottomInset: CGFloat!
    static func changeRatingMode(_ t: Bool, full: Bool){
        if lyrics && t {
            changeLyrics(false)
            updateRatings(ratings)
        }
        self.ratingMode = t
        self.full = full
        if full {
            self.remote.switchRatingCommands(t)
        }
        print("Rating mode is \(ratingMode)")
        defaults.set(t, forKey: "ratingMode")
        defaults.set(full, forKey: "fullRating")
    }
    
    static var ratings = [Rating]()
    static func updateRatings(_ t: [Rating]) {
        ratings = t
        var raw = [String]()
        for rating in ratings {
            raw.append(rating.rawValue)
        }
        defaults.set(raw, forKey: "ratings")
    }
    
    static var tint: Color!
    static func changeTint(_ t: Color){
        self.tint = t
        defaults.set(t.color.components.red, forKey: "tintRed")
        defaults.set(t.color.components.green, forKey: "tintGreen")
        defaults.set(t.color.components.blue, forKey: "tintBlue")
        defaults.set(t.color.components.alpha, forKey: "tintAlpha")
        defaults.set(t.name, forKey: "tintName")
    }
    
    static var theme: Theme = .adaptive
    static func changeTheme(_ t: Theme) {
        self.theme = t
        defaults.set(t.rawValue, forKey: "theme")
    }
    
    static var blur: Bool = false
    static func changeBlur(_ t: Bool) {
        self.blur = t
        defaults.set(t, forKey: "blur")
    }
    
    static var color: Bool = false
    static func changeColor(_ t: Bool) {
        self.color = t
        defaults.set(t, forKey: "color")
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
    
    static var popupDrag = false
    static func changePopupDrag(_ t: Bool) {
        self.popupDrag = t
        defaults.set(t, forKey: "popupDrag")
    }
    
    static func changeFeedbackContent(which: String, message: String, value: Int) {
        switch which {
        case "Like":
            remote.toggleLikeCommand(self.ratingMode)
            defaults.set(message, forKey: "likeMessage")
            defaults.set(value, forKey: "likeValue")
        case "Dislike":
            remote.toggleDislikeCommand(self.ratingMode)
            defaults.set(message, forKey: "dislikeMessage")
            defaults.set(value, forKey: "dislikeValue")
        case "Bookmark":
            remote.toggleBookmarkCommand(self.ratingMode)
            defaults.set(message, forKey: "bookmarkMessage")
            defaults.set(value, forKey: "bookmarkValue")
        default:
            print("Zla nazwa feedbacku")
        }
        remote.switchRatingCommands(self.ratingMode)
    }
    static var compact = true
    static func changeCompact(_ t: Bool){
        self.compact = t
        defaults.set(t, forKey: "compact")
    }
    enum Land: String {
        case artist = "artist"
        case album = "album"
        case songs = "songs"
    }
    static var landIn: Land = .album
    static func changeLanding(_ t: Land) {
        self.landIn = t
        defaults.set(t.rawValue, forKey: "landing")
    }
    static var lyrics = false
    static func changeLyrics(_ t: Bool) {
        if ratingMode && t{
            changeRatingMode(false, full: self.full)
        }
        self.lyrics = t
        self.remote.switchLyricsCommand(t)
        if t {
            Plum.shared.registerforDeviceLockNotification()
        }else{
            Plum.shared.unRegisterLockNotification()
        }
        defaults.set(t, forKey: "lyrics")
    }
}

func ==(left: GlobalSettings, right: GlobalSettings) -> Bool {
    return false
}
