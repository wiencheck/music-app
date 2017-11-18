//
//  SettingsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 31.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications

protocol SettingsDelegate {
    func enableRatingMode(enable: Bool)
}

class SettingsVC: UITableViewController, UITabBarControllerDelegate, MySpotlightDelegate {

    let defaults = UserDefaults.standard
    @IBOutlet weak var colorFlowSwitch: UISwitch!
    @IBOutlet weak var artistsGridSwitch: UISwitch!
    @IBOutlet weak var albumsGridSwitch: UISwitch!
    @IBOutlet weak var playlistsGridSwitch: UISwitch!
    @IBOutlet weak var spotlightButton: UIButton!
    @IBOutlet weak var spotlightSwitch: UISwitch!
    @IBOutlet weak var ratingSwitch: UISwitch!
    @IBOutlet weak var currentStyle: UILabel!
    @IBOutlet weak var currentMiniPlayer: UILabel!
    @IBOutlet weak var indexVisibleSwitch: UISwitch!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var lyricsSwitch: UISwitch!
    @IBOutlet weak var colorView: UIView!
    var colorFlowStatus: Bool!
    var artistsGridStatus: Bool!
    var albumsGridStatus: Bool!
    var spotlightStatus: Bool!
    var playlistsGridStatus: Bool!
    var ratingStatus: Bool!
    var lyricsStatus: Bool!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        tabBarController?.delegate = self
        musicQuery.shared.delegate = self
        spotlightButton.alpha = 1.0
        progressBar.alpha = 0.0
        handleSwitches()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
    }
    
    func handleSwitches(){
        colorFlowSwitch.addTarget(self, action: #selector(colorSwitched(_:)), for: .valueChanged)
        artistsGridSwitch.addTarget(self, action: #selector(artistsGrid(_:)), for: .valueChanged)
        albumsGridSwitch.addTarget(self, action: #selector(albumsGrid(_:)), for: .valueChanged)
        playlistsGridSwitch.addTarget(self, action: #selector(playlistsGrid(_:)), for: .valueChanged)
        spotlightSwitch.addTarget(self, action: #selector(spotlight(_:)), for: .valueChanged)
        ratingSwitch.addTarget(self, action: #selector(rating(_:)), for: .valueChanged)
        lyricsSwitch.addTarget(self, action: #selector(lyricsSwitched(_:)), for: .valueChanged)
    }
    
    @objc func colorSwitched(_ sender: UISwitch){
        if sender.isOn{
            colorFlowStatus = true
        }else{
            colorFlowStatus = false
        }
        defaults.set(colorFlowStatus, forKey: "colorFlow")
    }
    
    @objc func artistsGrid(_ sender: UISwitch){
        artistsGridStatus = sender.isOn
        defaults.set(artistsGridStatus, forKey: "artistsGrid")
    }
    
    @objc func albumsGrid(_ sender: UISwitch){
        albumsGridStatus = sender.isOn
        defaults.set(albumsGridStatus, forKey: "albumsGrid")
    }
    
    @objc func playlistsGrid(_ sender: UISwitch){
        playlistsGridStatus = sender.isOn
        defaults.set(playlistsGridStatus, forKey: "playlistsGrid")
    }
    
    @objc func rating(_ sender: UISwitch){
        ratingStatus = sender.isOn
        GlobalSettings.changeRatingMode(ratingStatus)
        ratingSwitch.isOn = ratingStatus
        defaults.set(ratingStatus, forKey: "ratingMode")
        if ratingStatus {
            lyricsStatus = false
            lyricsSwitch.isOn = false
            GlobalSettings.changeLyrics(false)
        }
    }
    
    @objc func lyricsSwitched(_ sender: UISwitch) {
        if sender.isOn{
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { enabled, error in
                if !enabled {
                    self.notificationPermissionError(error)
                }
            })
        }
        self.lyricsStatus = sender.isOn
        if lyricsStatus {
            ratingStatus = false
            ratingSwitch.isOn = false
            GlobalSettings.changeRatingMode(false)
        }
        GlobalSettings.changeLyrics(sender.isOn)
    }
    
    func notificationPermissionError(_ error: Error?) {
        if error != nil {
            print(error!)
        }
        let alert = UIAlertController(title: "Error", message: "You have to allow notifications for this feature to work. Fix in settings?", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK Computer", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true) {
            self.lyricsStatus = false
            self.lyricsSwitch.isOn = false
            GlobalSettings.changeLyrics(false)
        }
    }
    
    /////////////////////////////////////////
    @objc func spotlight(_ sender: UISwitch){
        if sender.isOn{
            spotlightStatus = true
            spotlightButton.isEnabled = true
        }else{
            let alert = UIAlertController(title: "Confirm", message: "This will delete entries from Spotlight, you will have to index them again", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Just do it!", style: .default, handler: {(action) in
                self.spotlightStatus = false
                musicQuery.shared.removeAllFromSpotlight()
            })
            let noAction = UIAlertAction(title: "This was a mistake", style: .cancel, handler: {(action) in
                self.spotlightSwitch.isOn = true
            })
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
        defaults.set(spotlightStatus, forKey: "spotlightActive")
        reload()
    }
    
    @objc func indexVisible(_ sender: UISwitch){
        GlobalSettings.changeIndexVisibility(sender.isOn)
    }
    
    @IBAction func spotlightBtnPressed(_ sender: UIButton){
        musicQuery.shared.removeAllFromSpotlight()
        UIView.animate(withDuration: 0.3, animations: {
            self.spotlightButton.alpha = 0.0
            self.progressBar.alpha = 1.0
        })
        timer.fire()
        musicQuery.shared.addToSpotlight()
    }
    
    @objc func updateProgressBar(){
        self.progressBar.setProgress(musicQuery.shared.spotlightProgress, animated: false)
        if self.progressBar.progress >= 0.99 {
            indexingEnded()
        }
    }
    
    func indexingEnded() {
        timer.invalidate()
        self.progressBar.setProgress(0, animated: false)
        UIView.animate(withDuration: 0.3, animations: {
            self.progressBar.alpha = 0.0
            self.spotlightButton.alpha = 1.0
        })
        self.spotlightButton.setTitle("Done!", for: .disabled)
    }
    
    func readCurrentSettings(){
        if let color = defaults.value(forKey: "colorFlow") as? Bool{
            colorFlowSwitch.isOn = color
            colorFlowStatus = color
        }
        if let artG = defaults.value(forKey: "artistsGrid") as? Bool{
            artistsGridSwitch.isOn = artG
            artistsGridStatus = artG
        }
        if let albG = defaults.value(forKey: "albumsGrid") as? Bool{
            albumsGridSwitch.isOn = albG
            albumsGridStatus = albG
        }
        if let playG = defaults.value(forKey: "playlistsGrid") as? Bool{
            playlistsGridSwitch.isOn = playG
            playlistsGridStatus = playG
        }
        if let spot = defaults.value(forKey: "spotlightActive") as? Bool{
            spotlightSwitch.isOn = spot
            spotlightStatus = spot
            spotlightButton.isEnabled = spot
        }
        if let rat = defaults.value(forKey: "ratingMode") as? Bool{
            ratingStatus = rat
            ratingSwitch.isOn = rat
        }
        if let sty = defaults.value(forKey: "style") as? Int{
            if sty == 0{
                currentStyle.text = "Light"
            }else if sty == 1{
                currentStyle.text = "Dark"
            }else if sty == 2{
                currentStyle.text = "Adaptive"
            }
        }
        if let pop = defaults.value(forKey: "modernPopup") as? Bool{
            if pop {
                currentMiniPlayer.text = "Modern"
            }else {
                currentMiniPlayer.text = "Classic"
            }
        }
        if let lyr = defaults.value(forKey: "lyrics") as? Bool{
            lyricsStatus = lyr
            lyricsSwitch.isOn = lyr
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        if (changed) {
            print("New tab order:")
            for i in 0 ..< viewControllers.count {
                defaults.set(viewControllers[i].tabBarItem.tag, forKey: String(i))
                print("\(i): \(viewControllers[i].tabBarItem.title!) (\(viewControllers[i].tabBarItem.tag))")
            }
        }
    }
    
    //0 - light, 1 - dark, 2 - adaptive
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                performSegue(withIdentifier: "colorflow", sender: nil)
            }else if indexPath.row == 1{
                explainBlur()
            }
            else if indexPath.row == 2{
                explainStyle()
            }else if indexPath.row == 3{
                performSegue(withIdentifier: "miniplayer", sender: nil)
            }else if indexPath.row == 5{
                performSegue(withIdentifier: "colors", sender: nil)
            }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                performSegue(withIdentifier: "rating", sender: nil)
            }else if indexPath.row == 1{
                performSegue(withIdentifier: "lyrics", sender: nil)
            }
        }else if indexPath.section == 2{
            if indexPath.row == 0{
                explainArtistsGrid()
            }else if indexPath.row == 1{
                explainAlbumsGrid()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reload(){
        readCurrentSettings()
        if spotlightSwitch.isOn {
            if musicQuery.shared.hasLibraryChanged(){
                spotlightButton.isEnabled = true
                spotlightButton.setTitle("Index content", for: .normal)
            }else{
                if spotlightStatus && spotlightSwitch.isOn{
                    spotlightButton.isEnabled = false
                    spotlightButton.setTitle("Spotlight records are up-to-date", for: .disabled)
                }
            }
        }else{
            spotlightButton.setTitle("Enable spotlight", for: .disabled)
            spotlightButton.isEnabled = false
        }
        progressBar.tintColor = GlobalSettings.tint.color
        colorView.backgroundColor = GlobalSettings.tint.color
        UISwitch.appearance().tintColor = GlobalSettings.tint.color
        UISwitch.appearance().onTintColor = GlobalSettings.tint.color
        spotlightButton.setTitleColor(GlobalSettings.tint.color, for: .normal)
    }
    
    func explainColorFlow(){
        let alert = UIAlertController(title: "Colorflow? What does that mean!?", message: "Easy there, ColorFlow is a cool and one of Plum's unique features that changes colors on now playing screen to match current playing song's artwork. And it looks awesome.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainBlur(){
        let alert = UIAlertController(title: "Blur!?", message: "If enabled, background of lyrics and UpNext will be blured, if not, you will be able to always see your beautiful artworks.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainStyle(){
        let alert = UIAlertController(title: "Time for decision", message: "Light: Certain elements on now playing screen, like lyrics background, UpNext background and upper bar will be white colored\n\nDark: Same as light, only it's totally opossite\n\nAdaptive: Light/Dark style will be enabled base on current artwork", preferredStyle: .actionSheet)
        let dark = UIAlertAction(title: "Always Dark", style: .default, handler: {(action) in
            self.defaults.set(1, forKey: "style")
            self.reload()
        })
        let light = UIAlertAction(title: "Always light", style: .default, handler: {(action) in
            self.defaults.set(0, forKey: "style")
            self.reload()
        })
        let adaptive = UIAlertAction(title: "Adaptive", style: .default, handler: {(action) in
            self.defaults.set(2, forKey: "style")
            self.reload()
        })
        alert.addAction(light)
        alert.addAction(dark)
        alert.addAction(adaptive)
        present(alert, animated: true, completion: nil)
    }
    
    func explainMiniPlayer(){
        let alert = UIAlertController(title: "Time for decision", message: "Modern: iOS 10 music app style\n\nClassic: iOS 9 music app style", preferredStyle: .actionSheet)
        let dark = UIAlertAction(title: "Modern", style: .default, handler: {(action) in
            GlobalSettings.changePopupStyle(.modern)
            let tab = self.tabBarController as! PlumTabBarController
            tab.reloadPopup(false)
            self.reload()
        })
        let light = UIAlertAction(title: "Classic", style: .default, handler: {(action) in
            GlobalSettings.changePopupStyle(.classic)
            let tab = self.tabBarController as! PlumTabBarController
            tab.reloadPopup(false)
            self.reload()
        })
        alert.addAction(light)
        alert.addAction(dark)
        present(alert, animated: true, completion: nil)
    }
    
    func explainArtistsGrid(){
        let alert = UIAlertController(title: "Artists grid?", message: "If enabled, artists view will become a grid instead of default table", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }
    
    func explainAlbumsGrid(){
        let alert = UIAlertController(title: "Albums grid?", message: "If enabled, albums view will become a grid instead of default table", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }
    
    func explainRatingMode(){
        let alert = UIAlertController(title: "Rating Mode?", message: "If enabled, you'll see ratings for each song right from the song view and also you will be able to rate current song from Lockscreen/ControlCenter", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    func explainSpotlight(){
        let alert = UIAlertController(title: "Spotlight?", message: "If enabled, you will be able to pick songs from anywhere outside the app. Just like in stock Music app.\nIt is recommended that you reindex every time there was a change in your library. If the Re-Index button is blue, you should click on it", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
