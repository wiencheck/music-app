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

class SettingsVC: UITableViewController, UITabBarControllerDelegate, MySpotlightDelegate {

    let defaults = UserDefaults.standard
    @IBOutlet weak var colorFlowSwitch: UISwitch!
    @IBOutlet weak var artistsGridSwitch: UISwitch!
    @IBOutlet weak var albumsGridSwitch: UISwitch!
    @IBOutlet weak var playlistsGridSwitch: UISwitch!
    @IBOutlet weak var spotlightButton: UIButton!
    @IBOutlet weak var ratingSwitch: UISwitch!
    @IBOutlet weak var currentStyle: UILabel!
    @IBOutlet weak var currentMiniPlayer: UILabel!
    @IBOutlet weak var indexVisibleSwitch: UISwitch!
    @IBOutlet weak var roundSwitch: UISwitch!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var lyricsSwitch: UISwitch!
    @IBOutlet weak var blurSwitch: UISwitch!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var deployLabel: UILabel!
    var colorFlowStatus: Bool!
    var artistsGridStatus: Bool!
    var albumsGridStatus: Bool!
    var playlistsGridStatus: Bool!
    var ratingStatus: Bool!
    var lyricsStatus: Bool!
    var blurStatus: Bool!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        tabBarController?.delegate = self
        musicQuery.shared.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, GlobalSettings.bottomInset, 0)
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
        ratingSwitch.addTarget(self, action: #selector(rating(_:)), for: .valueChanged)
        lyricsSwitch.addTarget(self, action: #selector(lyricsSwitched(_:)), for: .valueChanged)
        blurSwitch.addTarget(self, action: #selector(blurSwitched(_:)), for: .valueChanged)
        roundSwitch.addTarget(self, action: #selector(roundSwitched(_:)), for: .valueChanged)
    }
    
    @objc func colorSwitched(_ sender: UISwitch){
        colorFlowStatus = sender.isOn
        if GlobalSettings.blur {
            blurSwitch.isOn = false
            GlobalSettings.changeBlur(false)
        }
        defaults.set(colorFlowStatus, forKey: "colorFlow")
    }
    
    @objc func blurSwitched(_ sender: UISwitch){
        if GlobalSettings.color {
            colorFlowSwitch.isOn = false
            GlobalSettings.changeColor(false)
        }
        GlobalSettings.changeBlur(sender.isOn)
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
        if ratingStatus {
            lyricsStatus = false
            lyricsSwitch.isOn = false
            //GlobalSettings.changeLyrics(false)
        }
        GlobalSettings.changeRating(ratingStatus)
        ratingSwitch.isOn = ratingStatus
        defaults.set(ratingStatus, forKey: "rating")
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
            //GlobalSettings.changeRating(false, full: GlobalSettings.full)
        }
        GlobalSettings.changeLyrics(sender.isOn)
    }
    
    @objc func roundSwitched(_ sender: UISwitch) {
        GlobalSettings.changeRound(sender.isOn)
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
    
    @IBAction func spotlightBtnPressed(){
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
        self.progressBar.setProgress(0, animated: false)
        UIView.animate(withDuration: 0.3, animations: {
            self.progressBar.alpha = 0.0
            self.spotlightButton.alpha = 1.0
        })
        self.spotlightButton.setTitle("Done!", for: .disabled)
        timer.invalidate()
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
            spotlightButton.isEnabled = spot
        }
        if let rat = defaults.value(forKey: "rating") as? Bool{
            ratingStatus = rat
            ratingSwitch.isOn = rat
        }
        currentStyle.text = GlobalSettings.theme.rawValue
        if GlobalSettings.popupStyle == .modern {
            currentMiniPlayer.text = "Modern"
        }else{
            currentMiniPlayer.text = "Classic"
        }
        lyricsStatus = GlobalSettings.lyrics
        lyricsSwitch.isOn = GlobalSettings.lyrics
        blurSwitch.isOn = GlobalSettings.blur
        roundSwitch.isOn = GlobalSettings.round
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
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier
            else { return }
        switch identifier {
        case "colorflow":
            performSegue(withIdentifier: "scale", sender: nil)
        case "theme":
            explainStyle()
        case "miniplayer":
            explainMiniPlayer()
        case "tint":
            performSegue(withIdentifier: "colors", sender: nil)
        case "skip":
            explainSkip()
        case "rating":
            explainrating()
        case "ratingset":
            performSegue(withIdentifier: "setratings", sender: nil)
        case "lyrics":
            explainLyrics()
        case "lyricset":
            performSegue(withIdentifier: "lyricsSettings", sender: nil)
        case "artist":
            explainArtistsGrid()
        case "album":
            explainAlbumsGrid()
        case "playlist":
            explainPlaylistGrid()
        case "deploy":
            explainDeploy()
        case "indexing":
            spotlightBtnPressed()
        default:
            selfExplanatory()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reload(){
        readCurrentSettings()
        spotlightButton.setTitle("Reindex Spotlight content", for: .normal)
        progressBar.tintColor = GlobalSettings.tint.color
        colorView.backgroundColor = GlobalSettings.tint.color
        spotlightButton.setTitleColor(GlobalSettings.tint.color, for: .normal)
        deployLabel.text = GlobalSettings.deployIn.rawValue
    }
    
    func selfExplanatory() {
        let alert = UIAlertController(title: "🤔", message: "Well, this is really self-explanatory. Try it and see for yourself!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay, don't be mad!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainSkip() {
        let alert = UIAlertController(title: "Skip songs? Why?", message: "If enabled, Plum will not play songs automatically that have no rating, but you can still pick a song to play even if it doesn't have rating. It won't skip songs in user created queue", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainLyrics() {
        let alert = UIAlertController(title: "Lyrics mode? What?", message: "If enabled, you will get lyrics for now playing song delivered right to your lockscreen. And they will change automatically too. It only works with lyrics embedeed in song's tags, Plum does not download lyrics from the internet", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainPlaylistGrid() {
        let alert = UIAlertController(title: "Playlists grid?", message: "If enabled, playlists view will become a grid instead of default table", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainDeploy() {
        let alert = UIAlertController(title: "Where do we land, general?", message: "You can choose whether you prefer to start playing an album, artist, or all songs, when starting playback from Spotlight or in-app search screen", preferredStyle: .actionSheet)
        let album = UIAlertAction(title: "Album (default)", style: .default, handler: {(action) in
            GlobalSettings.changeDeploy(Deploy(rawValue: "Album")!)
            self.reload()
        })
        let artist = UIAlertAction(title: "Artist", style: .default, handler: {(action) in
            GlobalSettings.changeDeploy(Deploy(rawValue: "Artist")!)
            self.reload()
        })
        let playlist = UIAlertAction(title: "Songs", style: .default, handler: {(action) in
            self.defaults.set("Songs", forKey: "deploy")
            self.reload()
        })
        alert.addAction(album)
        alert.addAction(artist)
        //alert.addAction(playlist)
        present(alert, animated: true, completion: nil)
    }
    
    func explainColorFlow(){
        let alert = UIAlertController(title: "Colorflow? What does that mean!?", message: "Easy there, ColorFlow is a cool and one of Plum's unique features that changes colors on now playing screen to match current playing song's artwork. And it looks awesome.", preferredStyle: .alert)
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
        let alert = UIAlertController(title: "Time for decision", message: "Classic: iOS 9 music app styleModern: iOS 10 music app style\n\nModern: iOS 10 music app style", preferredStyle: .actionSheet)
        let dark = UIAlertAction(title: "Modern", style: .default, handler: {(action) in
            let tab = self.tabBarController as! PlumTabBarController
            GlobalSettings.changePopupStyle(.modern)
            tab.setPopup()
            self.reload()
        })
        let light = UIAlertAction(title: "Classic", style: .default, handler: {(action) in
            GlobalSettings.changePopupStyle(.classic)
            let tab = self.tabBarController as! PlumTabBarController
            tab.setPopup()
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
    
    func explainrating(){
        let alert = UIAlertController(title: "Rating Mode?", message: "If enabled, you'll see ratings for each song right from the song view and also you will be able to rate current song from Lockscreen/ControlCenter", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
}
