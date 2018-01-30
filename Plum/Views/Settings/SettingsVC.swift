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
    @IBOutlet weak var oledSwitch: UISwitch!
    //@IBOutlet weak var searchTopSwitch: UISwitch!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var deployLabel: UILabel!
    @IBOutlet weak var artG :UILabel!
    @IBOutlet weak var albG :UILabel!
    @IBOutlet weak var playG :UILabel!
    @IBOutlet weak var appI :UILabel!
    @IBOutlet weak var them :UILabel!
    @IBOutlet weak var miniS :UILabel!
    @IBOutlet weak var tintC :UILabel!
    @IBOutlet weak var rounS :UILabel!
    @IBOutlet weak var ratM :UILabel!
    @IBOutlet weak var ratSet :UILabel!
    @IBOutlet weak var lyrM :UILabel!
    @IBOutlet weak var abou :UILabel!
    @IBOutlet weak var doubT :UILabel!
    @IBOutlet weak var landI: UILabel!
    @IBOutlet weak var oledL: UILabel!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        updateTheme()
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
        self.tabBarController?.tabBar.tintColor = GlobalSettings.tint.color
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UITableViewCell.appearance().backgroundColor = .clear
        UILabel.appearance().tintColor = nil
        
    }
    
    func handleSwitches(){
        artistsGridSwitch.addTarget(self, action: #selector(artistsGrid(_:)), for: .valueChanged)
        albumsGridSwitch.addTarget(self, action: #selector(albumsGrid(_:)), for: .valueChanged)
        playlistsGridSwitch.addTarget(self, action: #selector(playlistsGrid(_:)), for: .valueChanged)
        ratingSwitch.addTarget(self, action: #selector(rating(_:)), for: .valueChanged)
        lyricsSwitch.addTarget(self, action: #selector(lyricsSwitched(_:)), for: .valueChanged)
        roundSwitch.addTarget(self, action: #selector(roundedSliderSwitched(_:)), for: .valueChanged)
        doubleBarSwitch.addTarget(self, action: #selector(doubleBarSwitched(_:)), for: .valueChanged)
        oledSwitch.addTarget(self, action: #selector(oledSwitched(_:)), for: .valueChanged)
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
    
    @objc func oledSwitched(_ sender: UISwitch) {
        GlobalSettings.changeOled(sender.isOn)
        GlobalSettings.changeTheme(GlobalSettings.theme)
        updateTheme()
        NotificationCenter.default.post(name: .themeChanged, object: nil)
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
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 6
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0:     //Grid
//            return 3
//        case 1:     //Appearance
//            return 5
//        case 2:     //Ratings
//            return 2
//        case 3:     //Lyrics
//            return 1
//        case 4:     //Search
//            return 2
//        case 5:     //Other
//            return 2
//        default:
//            return 0
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch indexPath.section {
//        case 0:     //Grid
//            let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! SwitchCell
//            switch indexPath.row {
//            case 0:
//                cell.setup(title: "Artists", on: GlobalSettings.artistsGrid)
//            case 1:
//                cell.setup(title: "Albums", on: GlobalSettings.albumsGrid)
//            default:
//                cell.setup(title: "Playlists", on: GlobalSettings.playlistsGrid)
//            }
//            return cell
//        case 1:     //Appearance
//            switch indexPath.row {
//            case 0:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailCell
//                cell.setup(title: "App icon", detail: "")
//                return cell
//            case 1:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailCell
//                cell.setup(title: "Theme", detail: GlobalSettings.theme.rawValue)
//                return cell
//            case 2:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailCell
//                cell.setup(title: "Miniplayer style", detail: GlobalSettings.popupStyle.rawValue)
//                return cell
//            case 3:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "tint", for: indexPath) as! ColorTintCell
//                cell.setup(title: "Tint color", color: GlobalSettings.tint.color)
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! SwitchCell
//                cell.setup(title: "Rounded now-playing slider", on: GlobalSettings.roundedSlider)
//                return cell
//            }
//        case 2:     //Ratings
//            switch indexPath.row {
//            case 0:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! SwitchCell
//                cell.setup(title: "Rating mode", on: GlobalSettings.rating)
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailCell
//                cell.setup(title: "Setting", detail: "")
//                return cell
//            }
//        case 3:     //Lyrics
//            let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as! SwitchCell
//            cell.setup(title: "Lyrics mode", on: GlobalSettings.lyrics)
//            return cell
//        case 4:     //Search
//            let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailCell
//            cell.setup(title: "Land in", detail: GlobalSettings.deployIn.rawValue)
//            return cell
//        case 5:     //Other
//            switch indexPath.row {
//            case 0:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailCell
//                cell.setup(title: "About", detail: "")
//                return cell
//            default:
//                let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath) as!
//                SwitchCell
//                cell.setup(title: "Double tap on playing bar", on: GlobalSettings.doubleBar)
//                return cell
//            }
//        default:
//            return UITableViewCell()
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier
            else { return }
        switch identifier {
        case "colorflow":
            performSegue(withIdentifier: "scale", sender: nil)
        case "blur":
            later()
        case "theme":
            explainStyle()
        case "oled":
            explainOled()
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
        oledSwitch.isOn = GlobalSettings.oled
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
        let alert = UIAlertController(title: "Time for decision", message: "Light: Certain elements on now playing screen, like lyrics background, UpNext background and upper bar will be white colored\n\nDark: Same as light, only it's totally opposite\n\nMixed: Navigation elements will be dark, while content will be light", preferredStyle: .actionSheet)
        let dark = UIAlertAction(title: "Dark", style: .default, handler: {(action) in
            GlobalSettings.changeTheme(.dark)
            self.reload()
            self.updateTheme()
        })
        let light = UIAlertAction(title: "Light", style: .default, handler: {(action) in
            GlobalSettings.changeTheme(.light)
            self.reload()
            self.updateTheme()
        })
        let mixed = UIAlertAction(title: "Mixed", style: .default, handler: {(action) in
            GlobalSettings.changeTheme(.mixed)
            self.reload()
            self.updateTheme()
        })
        alert.addAction(light)
        alert.addAction(dark)
        //alert.addAction(mixed)
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
    
    func explainOled() {
        let alert = UIAlertController(title: "High contrast?", message: "If enabled, background will be purely black, this mode is great for OLED screens like in the iPhone X", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Cool!", style: .default, handler: nil)
        alert.addAction(ok)
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
    
    func updateTheme() {
        tableView.backgroundColor = UIColor.background
        artG.textColor = UIColor.mainLabel
        albG.textColor = UIColor.mainLabel
        playG.textColor = UIColor.mainLabel
        appI.textColor = UIColor.mainLabel
        them.textColor = UIColor.mainLabel
        miniS.textColor = UIColor.mainLabel
        tintC.textColor = UIColor.mainLabel
        rounS.textColor = UIColor.mainLabel
        ratM.textColor = UIColor.mainLabel
        ratSet.textColor = UIColor.mainLabel
        lyrM.textColor = UIColor.mainLabel
        abou.textColor = UIColor.mainLabel
        doubT.textColor = UIColor.mainLabel
        landI.textColor = UIColor.mainLabel
        oledL.textColor = UIColor.mainLabel
        tableView.separatorColor = UIColor.separator
        if GlobalSettings.theme == .dark {
            navigationController?.navigationBar.barStyle = .blackTranslucent
            UITextField.appearance().keyboardAppearance = .dark
            //UITableViewCell.appearance().backgroundColor = .black
        }else{
            navigationController?.navigationBar.barStyle = .default
            UITextField.appearance().keyboardAppearance = .light
            //UITableViewCell.appearance().backgroundColor = .white
        }
        tableView.reloadData()
    }
    
//    func setColors() {
//        if GlobalSettings.theme == .dark {
//            if GlobalSettings.oled {
//                UIColor.background = UIColor.black
//            }else{
//                UIColor.background = UIColor.darkBackground
//            }
//            UIColor.mainLabel = UIColor.white
//            UIColor.detailLabel = UIColor.lightGray
//            UIColor.separator = UIColor.darkSeparator
//            UIColor.indexBackground = UIColor.darkGray
//            UIStatusBarStyle.themed = UIStatusBarStyle.lightContent
//        }else{
//            UIColor.mainLabel = UIColor.black
//            UIColor.detailLabel = UIColor.gray
//            UIColor.separator = UIColor.lightSeparator
//            UIColor.background = UIColor.lightBackground
//            UIColor.indexBackground = UIColor.white
//            UIStatusBarStyle.themed = UIStatusBarStyle.default
//        }
//    }
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
