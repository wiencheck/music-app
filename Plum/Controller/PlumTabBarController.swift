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
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        self.tabBar.tintColor = GlobalSettings.tint.color
        self.tabBarController?.moreNavigationController.navigationBar.tintColor = GlobalSettings.tint.color
        self.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color], for: UIControlState.normal)
        self.tabBar.unselectedItemTintColor = UIColor.gray
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updatePopup), name: NSNotification.Name(rawValue: "playBackStateChanged"), object: nil)
        nextBtn = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextBtnPressed))
        setPopup()
        emptyPopup()
        //loadAllViews()
        /*if let firstNav = self.viewControllers?.first as? UINavigationController{
            if let first = firstNav.viewControllers.first as? SearchVC{
                self.selectedIndex = 1
            }else{
                self.selectedIndex = 0
            }
        }*/
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
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
