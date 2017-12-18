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
    
    var nowPlaying: EightNowPlayingVC!
    let player = Plum.shared
    var timer: Timer!
    var playBackBtn: UIBarButtonItem!
    var nextBtn: UIBarButtonItem!
    var elapsed: Float!
    var duration: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //_ = viewControllers?.first
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        self.tabBar.tintColor = GlobalSettings.tint.color
        moreNavigationController.navigationBar.tintColor = GlobalSettings.tint.color
        self.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color], for: UIControlState.normal)
        self.tabBar.unselectedItemTintColor = UIColor.gray
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updatePopup), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        nextBtn = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextBtnPressed))
        setPopup()
        emptyPopup()
    }
    
    override func viewDidLayoutSubviews() {
//        if !UserDefaults.standard.bool(forKey: "greeting") {
//            let a = UIAlertController(title: "Hey there!", message: "Welcome to Plum, I hope you will find using it an enjoyable experience :)", preferredStyle: .alert)
//            a.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: {_ in
//                self.instruct("index", message: "Drag your finger on the right edge of the screen to quickly scroll through your library", completion: {
//                    UserDefaults.standard.set(true, forKey: "greeting")
//                })
//            }))
//            present(a, animated: true, completion: nil)
//        }
        DispatchQueue.global(qos: .background).async {
            musicQuery.shared.setArrays()
            //self.loadAllViews()
            if let count = UserDefaults.standard.value(forKey: "count") as? Int {
                if count != (musicQuery.shared.songs.count) {
                    musicQuery.shared.removeAllFromSpotlight()
                    musicQuery.shared.addToSpotlight()
                    /*self.instruct("spotlight", message: "Spinning wheel in status bar means that Plum is indexing all your songs and playlists so you will be able to search them from Spotlight\nIf you can't see any results be sure to enable Plum in Spotlight settings and launch indexing from the settings", completion: nil)
                    UserDefaults.standard.set(musicQuery.shared.songs.count, forKey: "count")*/
                }
            }else{
                UserDefaults.standard.set(musicQuery.shared.songs.count, forKey: "count")
                musicQuery.shared.removeAllFromSpotlight()
                /*self.instruct("spotlight", message: "Spinning wheel in status bar means that Plum is indexing all your songs and playlists so you will be able to search them from Spotlight\nIf you can't see any results be sure to enable Plum in Spotlight settings and launch indexing from the settings", completion: nil)*/
                musicQuery.shared.addToSpotlight()
            }
        }
    }
    
    fileprivate func displayPermissionsError() {
        let alertVC = UIAlertController(title: "This is a demo", message: "Unauthorized or restricted access. Cannot play media. Fix in Settings?" , preferredStyle: .alert)
        
        //cancel
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            alertVC.addAction(settingsAction)
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        }
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func updateProgress() {
        elapsed = Float(player.player.currentTime)
        duration = Float(player.player.duration)
        let procent = Float(player.player.currentTime / player.player.duration)
        self.nowPlaying.popupItem.progress = procent
    }
    
    func emptyPopup() {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        nowPlaying = story.instantiateViewController(withIdentifier: "eight") as! EightNowPlayingVC
        self.presentPopupBar(withContentViewController: nowPlaying, animated: true, completion: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        timer.fire()
        popupPresented = true
        nowPlaying.popupItem.title = "Welcome to Plum"
        nowPlaying.popupItem.subtitle = "Pick some music to play"
        self.popupBar.isUserInteractionEnabled = false
    }
    
    @objc func updatePopup() {
        if !popupPresented {
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            nowPlaying = story.instantiateViewController(withIdentifier: "eight") as! EightNowPlayingVC
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
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
