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

class SettingsVC: UITableViewController, MySpotlightDelegate {

    let defaults = UserDefaults.standard
    @IBOutlet weak var artistsGridSwitch: UISwitch!
    @IBOutlet weak var albumsGridSwitch: UISwitch!
    @IBOutlet weak var playlistsGridSwitch: UISwitch!
    @IBOutlet weak var spotlightButton: UIButton!
    @IBOutlet weak var ratingSwitch: UISwitch!
    @IBOutlet weak var currentStyle: UILabel!
    @IBOutlet weak var currentMiniPlayer: UILabel!
    @IBOutlet weak var roundSwitch: UISwitch!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var lyricsSwitch: UISwitch!
    @IBOutlet weak var doubleBarSwitch: UISwitch!
    //@IBOutlet weak var searchTopSwitch: UISwitch!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var deployLabel: UILabel!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        tabBarController?.delegate = self
        musicQuery.shared.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(64, 0, GlobalSettings.bottomInset, 0)
        spotlightButton.alpha = 1.0
        progressBar.alpha = 0.0
        handleSwitches()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
        UITableViewCell.appearance().backgroundColor = .white
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    func handleSwitches(){
        artistsGridSwitch.addTarget(self, action: #selector(artistsGrid(_:)), for: .valueChanged)
        albumsGridSwitch.addTarget(self, action: #selector(albumsGrid(_:)), for: .valueChanged)
        playlistsGridSwitch.addTarget(self, action: #selector(playlistsGrid(_:)), for: .valueChanged)
        ratingSwitch.addTarget(self, action: #selector(rating(_:)), for: .valueChanged)
        lyricsSwitch.addTarget(self, action: #selector(lyricsSwitched(_:)), for: .valueChanged)
        roundSwitch.addTarget(self, action: #selector(roundedSliderSwitched(_:)), for: .valueChanged)
        doubleBarSwitch.addTarget(self, action: #selector(doubleBarSwitched(_:)), for: .valueChanged)
        //searchTopSwitch.addTarget(self, action: #selector(searchTopSwitched(_:)), for: .valueChanged)
    }
    
    @objc func searchTopSwitched(_ sender: UISwitch) {
        GlobalSettings.changeSearchOnTop(sender.isOn)
    }
    
    @objc func artistsGrid(_ sender: UISwitch){
        GlobalSettings.changeArtists(grid: sender.isOn)
    }
    
    @objc func albumsGrid(_ sender: UISwitch){
        GlobalSettings.changeAlbums(grid: sender.isOn)
    }
    
    @objc func playlistsGrid(_ sender: UISwitch){
        GlobalSettings.changePlaylists(grid: sender.isOn)
    }
    
    @objc func rating(_ sender: UISwitch){
        if sender.isOn {
            lyricsSwitch.isOn = false
            if #available(iOS 10.0, *) {
                GlobalSettings.changeLyrics(false)
            }
        }
        GlobalSettings.changeRating(sender.isOn)
    }
    
    @objc func lyricsSwitched(_ sender: UISwitch) {
        if #available(iOS 10.0, *) {
            if sender.isOn{
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { enabled, error in
                    if !enabled {
                        self.notificationPermissionError(error)
                    }
                })
            }
            if sender.isOn {
                ratingSwitch.isOn = false
                GlobalSettings.changeRating(false, full: GlobalSettings.full)
            }
            GlobalSettings.changeLyrics(sender.isOn)
        }else{
            updatePrompt()
        }
    }
    
    @objc func roundedSliderSwitched(_ sender: UISwitch) {
        GlobalSettings.changeRound(sender.isOn)
    }
    
    @objc func doubleBarSwitched(_ sender: UISwitch) {
        GlobalSettings.changeDoubleBar(sender.isOn)
        let tab = self.tabBarController as! PlumTabBarController
        if sender.isOn {
            self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 2
        }else{
            self.popupBar.popupOpenGestureRecognizer.numberOfTapsRequired = 1
        }
        tab.setPopup()
    }
    
    @available(iOS 10.0, *) func notificationPermissionError(_ error: Error?) {
        if error != nil {
            print(error!)
        }
        let alert = UIAlertController(title: "Error", message: "You have to allow notifications for this feature to work. Fix in settings?", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK Computer", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true) {
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier
            else { return }
        switch identifier {
        case "colorflow":
            performSegue(withIdentifier: "scale", sender: nil)
        case "blur":
            later()
            //changeIcon()
        case "theme":
            //explainStyle()
            later()
            //performSegue(withIdentifier: "icons", sender: nil)
        case "about":
            performSegue(withIdentifier: "about", sender: nil)
        case "miniplayer":
            explainMiniPlayer()
        case "tint":
            performSegue(withIdentifier: "colors", sender: nil)
        case "skip":
            explainSkip()
        case "rating":
            explainrating()
        case "ratingset":
            performSegue(withIdentifier: "ratings", sender: nil)
        case "lyrics":
            explainLyrics()
        case "lyricset":
            performSegue(withIdentifier: "lyricsSettings", sender: nil)
        case "artist":
            explainArtistsGrid()
            //changeIcon()
        case "album":
            explainAlbumsGrid()
        case "playlist":
            explainPlaylistGrid()
        case "deploy":
            explainDeploy()
        case "indexing":
            spotlightBtnPressed()
        case "icons":
            icons()
        default:
            selfExplanatory()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func icons() {
        if #available(iOS 10.3, *) {
            performSegue(withIdentifier: "icons", sender: nil)
        }else{
            let alert = UIAlertController(title: "Available only on iOS 10.3, or later", message: "To use this feature you have to update your software", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func reload(){
        spotlightButton.setTitle("Reindex Spotlight content", for: .normal)
        progressBar.tintColor = GlobalSettings.tint.color
        colorView.backgroundColor = GlobalSettings.tint.color
        spotlightButton.setTitleColor(GlobalSettings.tint.color, for: .normal)
        deployLabel.text = GlobalSettings.deployIn.rawValue
        artistsGridSwitch.isOn = GlobalSettings.artistsGrid
        albumsGridSwitch.isOn = GlobalSettings.albumsGrid
        playlistsGridSwitch.isOn = GlobalSettings.playlistsGrid
        ratingSwitch.isOn = GlobalSettings.rating
        lyricsSwitch.isOn = GlobalSettings.lyrics
        currentMiniPlayer.text = GlobalSettings.popupStyle.rawValue
        roundSwitch.isOn = GlobalSettings.roundedSlider
        currentStyle.text = GlobalSettings.theme.rawValue
        doubleBarSwitch.isOn = GlobalSettings.doubleBar
        //searchTopSwitch.isOn = GlobalSettings.searchOnTop
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
        let alert = UIAlertController(title: "Where do we land, general?", message: "You can choose whether you prefer to start playing an album, artist, or all songs, when starting playback from Spotlight or in-app search screen\nIf there is only one song in chosen destination, Plum will start playing all songs", preferredStyle: .actionSheet)
        let album = UIAlertAction(title: "Album", style: .default, handler: {(action) in
            GlobalSettings.changeDeploy(Deploy(rawValue: "Album")!)
            self.reload()
        })
        let artist = UIAlertAction(title: "Artist", style: .default, handler: {(action) in
            GlobalSettings.changeDeploy(Deploy(rawValue: "Artist")!)
            self.reload()
        })
        let songs = UIAlertAction(title: "Songs", style: .default, handler: {(action) in
            GlobalSettings.changeDeploy(Deploy(rawValue: "Songs")!)
            self.reload()
        })
        alert.addAction(album)
        alert.addAction(artist)
        alert.addAction(songs)
        present(alert, animated: true, completion: nil)
    }
    
//    func explainColorFlow(){
//        let alert = UIAlertController(title: "Colorflow? What does that mean!?", message: "Easy there, ColorFlow is a cool and one of Plum's unique features that changes colors on now playing screen to match current playing song's artwork. And it looks awesome.", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
//        alert.addAction(ok)
//        present(alert, animated: true, completion: nil)
//    }
    
    func explainStyle(){
        let alert = UIAlertController(title: "Time for decision", message: "Light: Certain elements on now playing screen, like lyrics background, UpNext background and upper bar will be white colored\n\nDark: Same as light, only it's totally opossite\n\nMixed: Navigation elements will be dark, while content will be light", preferredStyle: .actionSheet)
        let dark = UIAlertAction(title: "Dark", style: .default, handler: {(action) in
            GlobalSettings.changeTheme(.dark)
            self.reload()
            self.themeAlert()
        })
        let light = UIAlertAction(title: "Light", style: .default, handler: {(action) in
            GlobalSettings.changeTheme(.light)
            self.reload()
            self.themeAlert()
        })
        let mixed = UIAlertAction(title: "Mixed", style: .default, handler: {(action) in
            GlobalSettings.changeTheme(.mixed)
            self.reload()
            self.themeAlert()
        })
        alert.addAction(light)
        alert.addAction(dark)
        alert.addAction(mixed)
        present(alert, animated: true, completion: nil)
    }
    
    func themeAlert() {
        let a = UIAlertController(title: "Changing theme?", message: "Please restart the app for all changes to be enabled", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        a.addAction(ok)
        present(a, animated: true, completion: nil)
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
    
    func later() {
        let alert = UIAlertController(title: "😓", message: "Unfortunately this feature is not yet available, it will be enabled in near future!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Can't wait!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension SettingsVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        if (changed) {
            print("New tab order:")
            for i in 0 ..< viewControllers.count {
                defaults.set(viewControllers[i].tabBarItem.tag, forKey: String(i))
                print("\(i): \(viewControllers[i].tabBarItem.title!) (\(viewControllers[i].tabBarItem.tag))")
            }
        }
    }
}
