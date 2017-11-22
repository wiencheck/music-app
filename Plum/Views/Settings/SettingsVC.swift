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
    func enablerating(enable: Bool)
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
    @IBOutlet weak var blurSwitch: UISwitch!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var sliderLabel: UILabel!
    var colorFlowStatus: Bool!
    var artistsGridStatus: Bool!
    var albumsGridStatus: Bool!
    var spotlightStatus: Bool!
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
        blurSwitch.addTarget(self, action: #selector(blurSwitched(_:)), for: .valueChanged)
    }
    
    @objc func colorSwitched(_ sender: UISwitch){
        colorFlowStatus = sender.isOn
        if blurStatus {
            blurStatus = false
            blurSwitch.isOn = false
            GlobalSettings.changeBlur(false)
        }
        defaults.set(colorFlowStatus, forKey: "colorFlow")
    }
    
    @objc func blurSwitched(_ sender: UISwitch){
        blurStatus = sender.isOn
        if colorFlowStatus {
            colorFlowStatus = false
            colorFlowSwitch.isOn = false
            GlobalSettings.changeColor(false)
        }
        defaults.set(blurStatus, forKey: "blur")
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
        GlobalSettings.changeRating(ratingStatus, full: GlobalSettings.full)
        ratingSwitch.isOn = ratingStatus
        defaults.set(ratingStatus, forKey: "rating")
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
            GlobalSettings.changeRating(false, full: GlobalSettings.full)
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
                self.defaults.set(self.spotlightStatus, forKey: "spotlightActive")
                self.reload()
            })
            let noAction = UIAlertAction(title: "This was a mistake", style: .cancel, handler: {(action) in
                self.spotlightSwitch.isOn = true
                self.spotlightButton.setTitle("Enable Spotlight", for: .normal)
            })
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
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
        case "left":
            explainLeft()
        case "slider":
            explainSlider()
        case "artist":
            explainArtistsGrid()
        case "album":
            explainAlbumsGrid()
        case "playlist":
            explainPlaylistGrid()
        case "deploy":
            explainDeploy()
        case "spotlight":
            explainSpotlight()
        case "indexing":
            spotlightBtnPressed()
        default:
            selfExplanatory()
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
        spotlightButton.setTitleColor(GlobalSettings.tint.color, for: .normal)
        sliderLabel.text = GlobalSettings.slider.rawValue
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
    
    func explainLeft() {
        let alert = UIAlertController(title: "Oh now we're discriminating lefties, huh?", message: "Not really, it just changes few UI elements so it will be more comfortable to use the app and users won't be...left behind", preferredStyle: .alert)
        let ok = UIAlertAction(title: "This was the greatest pun in the history of mankind", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainSlider() {
        let alert = UIAlertController(title: "\"Ohh, let me slide\"", message: "Smooth: slider similar to what can be seen in most computer applications\n\nAlphabetical: similar to stock iOS slider (like in Contacts app) but with improved and more precise scrolling", preferredStyle: .alert)
        let smooth = UIAlertAction(title: "Smooth", style: .default, handler: { (action) in
            GlobalSettings.changeSlider(.smooth)
            self.reload()
        })
        let alp = UIAlertAction(title: "Alphabetical", style: .default, handler: { (action) in
            GlobalSettings.changeSlider(.alphabetical)
            self.reload()
        })
        alert.addAction(smooth)
        alert.addAction(alp)
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
            self.defaults.set("albums", forKey: "deploy")
            self.reload()
        })
        let artist = UIAlertAction(title: "Artist", style: .default, handler: {(action) in
            self.defaults.set("artist", forKey: "deploy")
            self.reload()
        })
        let playlist = UIAlertAction(title: "Songs", style: .default, handler: {(action) in
            self.defaults.set("songs", forKey: "deploy")
            self.reload()
        })
        alert.addAction(album)
        alert.addAction(artist)
        alert.addAction(playlist)
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
    
    func explainSpotlight(){
        let alert = UIAlertController(title: "Spotlight?", message: "If enabled, you will be able to pick songs from anywhere outside the app. Just like in stock Music app.\nIt is recommended that you reindex every time there was a change in your library. If the Re-Index button is blue, you should click on it", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
