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

enum styles: String {
    case modern = "modern"
    case classic = "classic"
}

enum Theme: String {
    case light = "light"
    case dark = "dark"
}

enum Deploy: String {
    case artist = "artist"
    case album = "album"
    case songs = "songs"
}

enum Slider: String {
    case alphabetical = "Alphabetical"
    case smooth = "Smooth"
}

struct GlobalSettings{
    static var remote: RemoteCommandManager!
    static let defaults = UserDefaults.standard
    static var rating = false                                       //UI
    static var full = false                                       //UI
    static var bottomInset: CGFloat!
    static var actions = [Rating]()
    static func changeRating(_ t: Bool, full: Bool = false){
        if lyrics && t {
            changeLyrics(false)
            updateRatings(ratings)
        }
        self.rating = t
        self.full = full
//        if full {
//            self.remote.switchRatingCommands(t)
//        }
        if t { actions = ratings }
        remote.switchRatingCommands(t)
        print("Rating mode is \(rating)")
        defaults.set(t, forKey: "rating")
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
    
    static var tint: Color!                                       //UI
    static func changeTint(_ t: Color){
        self.tint = t
        defaults.set(t.color.components.red, forKey: "tintRed")
        defaults.set(t.color.components.green, forKey: "tintGreen")
        defaults.set(t.color.components.blue, forKey: "tintBlue")
        defaults.set(t.color.components.alpha, forKey: "tintAlpha")
        defaults.set(t.name, forKey: "tintName")
    }
    
    static var theme: Theme = .light                                       //UI
    static func changeTheme(_ t: Theme) {
        self.theme = t
        defaults.set(t.rawValue, forKey: "theme")
    }
    
    static var blur: Bool = false                                       //UI
    static func changeBlur(_ t: Bool) {
        self.blur = t
        defaults.set(t, forKey: "blur")
    }
    
    static var color: Bool = false                                       //UI
    static func changeColor(_ t: Bool) {
        self.color = t
        defaults.set(t, forKey: "color")
    }
    
    static var scale: Double = 0
    static func changeScale(_ t: Double) {
        scale = t
        defaults.set(t, forKey: "scale")
    }
    
    static var alphabeticalSort = false
    static func changeAlphabeticalSort(_ t: Bool){
        self.alphabeticalSort = t
    }
    
    static var slider: Slider = .alphabetical                                       //UI
    static func changeSlider(_ t: Slider) {
        slider = t
        defaults.set(t.rawValue, forKey: "slider")
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
            remote.toggleLikeCommand(self.rating)
            defaults.set(message, forKey: "likeMessage")
            defaults.set(value, forKey: "likeValue")
        case "Dislike":
            remote.toggleDislikeCommand(self.rating)
            defaults.set(message, forKey: "dislikeMessage")
            defaults.set(value, forKey: "dislikeValue")
        case "Bookmark":
            remote.toggleBookmarkCommand(self.rating)
            defaults.set(message, forKey: "bookmarkMessage")
            defaults.set(value, forKey: "bookmarkValue")
        default:
            print("Zla nazwa feedbacku")
        }
        remote.switchRatingCommands(self.rating)
    }
    static var compact = true
    static func changeCompact(_ t: Bool){
        self.compact = t
        defaults.set(t, forKey: "compact")
    }
    static var deployIn: Deploy = .album
    static func changeDeploy(_ t: Deploy) {
        self.deployIn = t
        defaults.set(t.rawValue, forKey: "deploy")
    }
    static var lyrics = false
    static func changeLyrics(_ t: Bool) {
        if rating && t{
            changeRating(false, full: self.full)
        }
        self.lyrics = t
        if t {
            actions = [.show, .stopLyrics, .previous]
            Plum.shared.registerforDeviceLockNotification()
        }else{
            Plum.shared.unRegisterLockNotification()
        }
        self.remote.switchRatingCommands(t)
        defaults.set(t, forKey: "lyrics")
    }
    static var round = false
    static func changeRound(_ t: Bool) {
        round = t
    }
}

func ==(left: GlobalSettings, right: GlobalSettings) -> Bool {
    
    return false
}
