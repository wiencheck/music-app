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

public enum Sort: String {
    case alphabetically = "alphabetically"
    case album = "album"
    case yearAscending = "yearAscending"
    case yearDescending = "yearDescending"
}

enum styles: String {
    case modern = "Modern"
    case classic = "Classic"
}

enum Deploy: String {
    case artist = "Artist"
    case album = "Album"
    case songs = "Songs"
}

enum Theme: String {
    case light = "Light"
    case dark = "Dark"
    case mixed = "Mixed"
}

struct GlobalSettings{
    static var remote: RemoteCommandManager!
    static let defaults = UserDefaults.standard
    static var rating = false                                       //UI
    static var bottomInset: CGFloat!
    static var actions = [Rating]()
    static var device = ""
    static func setDevice(_ t: String) {
        device = t
    }
    static func changeRating(_ t: Bool){
        if lyrics && t {
            changeLyrics(false)
            updateRatings(ratings)
        }
        self.rating = t
        if t { actions = ratings }
        remote.switchRatingCommands(t)
        save(t, key: "rating")
    }
    
    static var ratings = [Rating]()
    static func updateRatings(_ t: [Rating]) {
        ratings = t
        var raw = [String]()
        for rating in ratings {
            raw.append(rating.rawValue)
        }
        save(raw, key: "ratings")
    }
    
    static var tint: Color!                                       //UI
    static func changeTint(_ t: Color){
        self.tint = t
        save(t.color.components.red, key: "tintRed")
        save(t.color.components.green, key: "tintGreen")
        save(t.color.components.blue, key: "tintBlue")
        save(t.color.components.alpha, key: "tintAlpha")
        save(t.name, key: "tintName")
    }
    
    static var theme = Theme.light                                   //UI
    static func changeTheme(_ t: Theme) {
        self.theme = t
        save(t.rawValue, key: "theme")
        if theme == .dark {
            if oled {
                UIColor.background = UIColor.black
                UIColor.separator = UIColor.darkSeparator.withAlphaComponent(0.5)
            }else{
                UIColor.background = UIColor.darkBackground
                UIColor.separator = UIColor.darkSeparator
            }
            UIColor.mainLabel = UIColor.white
            UIColor.detailLabel = UIColor.lightGray
            UIColor.indexBackground = UIColor.black
            UIStatusBarStyle.themed = UIStatusBarStyle.lightContent
            UITextField.appearance().keyboardAppearance = .dark
        }else{
            UIColor.mainLabel = UIColor.black
            UIColor.detailLabel = UIColor.gray
            UIColor.separator = UIColor.lightSeparator
            UIColor.background = UIColor.lightBackground
            UIColor.indexBackground = UIColor.white
            UIStatusBarStyle.themed = UIStatusBarStyle.default
            UITextField.appearance().keyboardAppearance = .light
        }
        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }
    
    static var ratingsIn = true
    static func changeRatingsIn(_ t: Bool){
        ratingsIn = t
        save(t, key: "ratingsIn")
    }
    
    static var blur: Bool = false                                       //UI
    static func changeBlur(_ t: Bool) {
        self.blur = t
        save(t, key: "blur")
    }
    
    static var color: Bool = false                                       //UI
    static func changeColor(_ t: Bool) {
        self.color = t
        save(t, key: "color")
    }
    
    static var scale: Double = 0
    static func changeScale(_ t: Double) {
        scale = t
        save(t, key: "scale")
    }
    
    static var artistSort: Sort = .alphabetically
    static func changeArtistSort(_ t: Sort){
        self.artistSort = t
        save(t.rawValue, key: "artistSort")
    }
    
    static var artistAlbumsSort = Sort.alphabetically
    static func changeArtistAlbumsSort(_ t: Sort){
        self.artistAlbumsSort = t
        save(t.rawValue, key: "artistAlbumsSort")
    }
    
    static var popupStyle: styles = .classic
    static func changePopupStyle(_ t: styles) {
        self.popupStyle = t
        if t == .classic {
            self.bottomInset = 40.0
            save(false, key: "modernPopup")
        }else {
            self.bottomInset = 64.0
            save(true, key: "modernPopup")
        }
    }
    
    static var popupDrag = false
    static func changePopupDrag(_ t: Bool) {
        self.popupDrag = t
        save(t, key: "popupDrag")
    }
    
    static var oled = false
    static func changeOled(_ t: Bool) {
        self.oled = t
        save(t, key: "oled")
    }
    
//    static func changeFeedbackContent(which: String, message: String, value: Int) {
//        switch which {
//        case "Like":
//            remote.toggleLikeCommand(self.rating)
//            defaults.set(message, forKey: "likeMessage")
//            defaults.set(value, forKey: "likeValue")
//        case "Dislike":
//            remote.toggleDislikeCommand(self.rating)
//            defaults.set(message, forKey: "dislikeMessage")
//            defaults.set(value, forKey: "dislikeValue")
//        case "Bookmark":
//            remote.toggleBookmarkCommand(self.rating)
//            defaults.set(message, forKey: "bookmarkMessage")
//            defaults.set(value, forKey: "bookmarkValue")
//        default:
//            print("Zla nazwa feedbacku")
//        }
//        remote.switchRatingCommands(self.rating)
//    }
//    static var compact = true
//    static func changeCompact(_ t: Bool){
//        self.compact = t
//        defaults.set(t, forKey: "compact")
//    }
    static var deployIn: Deploy = .album
    static func changeDeploy(_ t: Deploy) {
        self.deployIn = t
        save(t.rawValue, key: "deploy")
    }
    static var lyrics = false
    static func changeLyrics(_ t: Bool) {
        if rating && t{
            changeRating(false)
        }
        self.lyrics = t
        if t {
            actions = [.show, .stopLyrics, .previous]
            Plum.shared.registerforDeviceLockNotification()
        }else{
            Plum.shared.unRegisterLockNotification()
        }
        self.remote.switchRatingCommands(t)
        save(t, key: "lyrics")
    }
    static var roundedSlider = false
    static func changeRound(_ t: Bool) {
        roundedSlider = t
        save(roundedSlider, key: "roundedSlider")
    }
    static var doubleBar = true
    static func changeDoubleBar(_ t: Bool) {
        doubleBar = t
        save(doubleBar, key: "doubleBar")
    }
    static var playlistsGrid = false
    static func changePlaylists(grid: Bool) {
        playlistsGrid = grid
        save(grid, key: "playlistsGrid")
    }
    static var albumsGrid = false
    static func changeAlbums(grid: Bool) {
        albumsGrid = grid
        save(grid, key: "albumsGrid")
    }
    static var artistsGrid = false
    static func changeArtists(grid: Bool) {
        artistsGrid = grid
        save(grid, key: "artistsGrid")
    }
    static func save(_ data: Any, key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    static var trial = true
    static func changeTrial(_ t: Bool) {
        trial = t
        NotificationCenter.default.post(name: .unlockChanged, object: nil, userInfo: ["state": trial])
        save(trial, key: "lite")
    }
}
