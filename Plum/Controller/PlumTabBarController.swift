//
//  PlumTabBarController.swift
//  wiencheck
//
//  Created by Adam Wienconek on 17.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//
import UIKit

public var popupPresented = false

class PlumTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var popupActive = false
    
    var nowPlaying: NowPlayingViewController!
    let player = Plum.shared
    var timer: Timer!
    var playBackBtn: UIBarButtonItem!
    var nextBtn: UIBarButtonItem!
    var elapsed: Float!
    var duration: Float!
    var identifier: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updatePopup), name: .playbackChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
        nextBtn = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextBtnPressed))
        identifier = setIdentifier()
        setPopup()
        emptyPopup()
        updateTheme()
        DispatchQueue.global(qos: .background).async {
            musicQuery.shared.setArrays()
            if let count = UserDefaults.standard.value(forKey: "count") as? Int {
                let c = musicQuery.shared.songs.count
                if count != c {
                    UserDefaults.standard.set(c, forKey: "count")
                    musicQuery.shared.removeAllFromSpotlight()
                    musicQuery.shared.addToSpotlight()
                    self.instruct("spotlight", message: "Spinning wheel in status bar means that Plum is indexing all your songs and playlists so you will be able to search them from Spotlight\nIf you can't see any results be sure to enable Plum in Spotlight settings and launch indexing from the settings", completion: nil)
                }
            }else{
                UserDefaults.standard.set(musicQuery.shared.songs.count, forKey: "count")
                musicQuery.shared.removeAllFromSpotlight()
                self.instruct("spotlight", message: "Spinning wheel in status bar means that Plum is indexing all your songs and playlists so you will be able to search them from Spotlight\nIf you can't see any results be sure to enable Plum in Spotlight settings and launch indexing from the settings", completion: nil)
                musicQuery.shared.addToSpotlight()
            }
        }
    }
    
    @objc func updateTheme() {
        if GlobalSettings.theme == .light {
            tabBar.barStyle = .default
        }else{
            tabBar.barStyle = .black
        }
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.themed
        tabBar.tintColor = GlobalSettings.tint.color
        self.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color], for: .selected)
        customizeMoreTab()
        updatePopupBarAppearance()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        instruct("miniplayer", message: "Tap on the miniplayer bar or drag it upwards to open now playing view.\nGo to settings to enable double tap to open.", completion: nil)
        instruct("slider", message: "Swipe on the right edge of the screen to use quick scrolling", completion: nil)
    }
    
    @objc func updateProgress() {
        elapsed = Float(player.player.currentTime)
        duration = Float(player.player.duration)
        let procent = Float(player.player.currentTime / player.player.duration)
        self.nowPlaying.popupItem.progress = procent
    }
    
    func emptyPopup() {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        nowPlaying = story.instantiateViewController(withIdentifier: identifier) as! NowPlayingViewController
        nowPlaying.tab = self
        self.presentPopupBar(withContentViewController: nowPlaying, animated: true, completion: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        timer.fire()
        popupPresented = true
        nowPlaying.popupItem.title = "Welcome to Plum"
        nowPlaying.popupItem.subtitle = "Pick some music to play"
        popupBar.isUserInteractionEnabled = popupActive
    }
    
    @objc func updatePopup() {
        if !popupPresented {
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            nowPlaying = story.instantiateViewController(withIdentifier: identifier) as! NowPlayingViewController
            nowPlaying.tab = self
            self.presentPopupBar(withContentViewController: nowPlaying, animated: true, completion: nil)
            popupPresented = true
        }
        if popupPresented {
            if Plum.shared.currentItem == nil {
                dismissPopupBar(animated: true, completion: {popupPresented = false})
            }else{
                nowPlaying.popupItem.title = player.currentItem?.title ?? "Unknown title"
                nowPlaying.popupItem.subtitle = player.currentItem?.artist ?? "Unknown artist"
                if !player.isPlayin(){
                    playBackBtn = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playback))
                }else {
                    playBackBtn = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(playback))
                }
                nowPlaying.popupItem.leftBarButtonItems = [playBackBtn]
                nowPlaying.popupItem.rightBarButtonItems = [nextBtn]
                nowPlaying.popupItem.image = player.currentItem?.artwork?.image(at: CGSize(width: 30, height: 30))
                self.popupBar.isUserInteractionEnabled = true
            }
        }
        
    }
    
    @objc func playback() {
        player.togglePlayPause()
    }
    
    @objc func nextBtnPressed() {
        player.next()
        player.play()
    }
    
        func loadAllViews() {
            self.viewControllers?.forEach {
                if let navController = $0 as? UINavigationController {
                    let _ = navController.topViewController?.view
                } else {
                    let _ = $0.view.description
                }
            }
        }
    
    func setPopup() {
        if GlobalSettings.popupStyle == .classic {
            self.popupBar.barStyle = .compact
            self.popupInteractionStyle = .drag
            self.popupBar.progressViewStyle = .bottom
            self.popupContentView.popupCloseButtonStyle = .none
            if GlobalSettings.doubleBar {
                self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 2
            }else{
                self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 1
            }
            print("classic")
        } else {
            self.popupBar.barStyle = .prominent
            self.popupInteractionStyle = .snap
            self.popupBar.progressViewStyle = .bottom
            self.popupContentView.popupCloseButtonStyle = .none
            if GlobalSettings.doubleBar {
                self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 2
            }else{
                self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 1
            }
            print("modern")
        }
    }
    
    func customizeMoreTab() {
        let bar = moreNavigationController.navigationBar
        if GlobalSettings.theme == .light {
            bar.barStyle = .default
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        }else{
            bar.barStyle = .blackTranslucent
            bar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        if let more = self.moreNavigationController.topViewController?.view as? UITableView {
            //more.delegate = self
            more.tableFooterView = UIView()
            more.tintColor = GlobalSettings.tint.color
            if GlobalSettings.theme == .dark {
                more.backgroundColor = UIColor.darkBackground
                more.separatorColor = UIColor.darkSeparator
                for cell in more.visibleCells {
                    cell.backgroundColor = .clear
                    cell.textLabel?.textColor = UIColor.white
                }
            }else{
                more.backgroundColor = UIColor.lightBackground
                more.separatorColor = UIColor.lightSeparator
                for cell in more.visibleCells {
                    cell.backgroundColor = .clear
                    cell.textLabel?.textColor = UIColor.black
                }
            }
        }
        
    }
    
    func setIdentifier() -> String{
        let device = GlobalSettings.device
        var _identifier = ""
        _identifier = "eight"
        if device == "iPhone 5" || device == "iPhone 5s" || device == "iPhone 5c" || device == "iPhone SE" || device == "iPod Touch 6" {
            _identifier += "_se"
        }else if device == "iPhone 6" || device == "iPhone 6s" || device == "iPhone 7" || device == "iPhone 8" {
            _identifier += "_6"
        }else if device == "iPhone 6 Plus" || device == "iPhone 6s Plus" || device == "iPhone 7 Plus" || device == "iPhone 8 Plus" {
            _identifier += "_6plus"
        }else if device == "iPhone X" {
            _identifier += "_x"
        }else if device.contains("iPad"){
            _identifier += "_se"
        }else{
            _identifier += "_6plus"
        }
        return _identifier
    }
    
}


