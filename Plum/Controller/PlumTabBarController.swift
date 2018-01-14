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
    
    var nowPlaying: EightNowPlayingVC!
    let player = Plum.shared
    var timer: Timer!
    var playBackBtn: UIBarButtonItem!
    var nextBtn: UIBarButtonItem!
    var elapsed: Float!
    var duration: Float!
    var identifier: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //_ = viewControllers?.first
        self.tabBar.tintColor = GlobalSettings.tint.color
        if GlobalSettings.theme == .light {
            tabBar.barStyle = .default
        }else{
            tabBar.barStyle = .black
        }
        moreNavigationController.navigationBar.tintColor = GlobalSettings.tint.color
        self.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color], for: UIControlState.normal)
        //self.tabBar.unselectedItemTintColor = UIColor.gray
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updatePopup), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        nextBtn = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextBtnPressed))
        identifier = setIdentifier()
        setPopup()
        emptyPopup()
        _ = musicQuery.shared.allSongs()
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
        customizeMoreTab()
    }
    
//    fileprivate func displayPermissionsError() {
//        let alertVC = UIAlertController(title: "This is a demo", message: "Unauthorized or restricted access. Cannot play media. Fix in Settings?" , preferredStyle: .alert)
//        
//        //cancel
//        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
//            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
//            if #available(iOS 10.0, *) {
//                let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
//                    UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
//                })
//            }
//            alertVC.addAction(settingsAction)
//        } else {
//            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
//        }
//        present(alertVC, animated: true, completion: nil)
//    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        instruct("miniplayer", message: "Tap twice on the miniplayer bar or drag it upwards to open now playing view", completion: nil)
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
        nowPlaying = story.instantiateViewController(withIdentifier: identifier) as! EightNowPlayingVC
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
            nowPlaying = story.instantiateViewController(withIdentifier: identifier) as! EightNowPlayingVC
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
            self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 2
            print("classic")
        } else {
            self.popupBar.barStyle = .prominent
            self.popupInteractionStyle = .snap
            self.popupBar.progressViewStyle = .bottom
            self.popupContentView.popupCloseButtonStyle = .none
            self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 2
            print("modern")
        }
    }
    
    func customizeMoreTab() {
        if let more = self.moreNavigationController.topViewController?.view as? UITableView {
            //more.delegate = self
            more.backgroundColor = UIColor.lightBackground
            more.separatorStyle = .none
            for cell in more.visibleCells {
                cell.backgroundColor = .clear
                cell.textLabel?.textColor = UIColor.black
            }
        }
        
    }
    
    func setIdentifier() -> String{
        if device == "iPhone 5" || device == "iPhone 5s" || device == "iPhone 5c" || device == "iPhone SE" || device == "iPod Touch 6" {
            return "eight_se"
        }else if device == "iPhone 6" || device == "iPhone 6s" || device == "iPhone 7" || device == "iPhone 8" {
            return "eight_6"
        }else if device == "iPhone 6 Plus" || device == "iPhone 7 Plus" || device == "iPhone 8 Plus" {
            return "eight_6plus"
        }else if device == "iPhone X" {
            return "eight_x"
        }else if device.contains("iPad"){
            return "eight_se"
        }else{
            return "eight_6"
        }
    }
    
}


