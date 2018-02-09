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
    
    //Info/kontakt
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var browserBtn: UIButton!
    @IBOutlet weak var mailBtn: UIButton!
    @IBOutlet weak var storeBtn: UIButton!

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
    @IBOutlet weak var ratingsInSwitch: UISwitch!
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
    @IBOutlet weak var ratingsInL: UILabel!
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
        setVersion()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
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
        ratingsInSwitch.addTarget(self, action: #selector(ratingsInSwitched(_:)), for: .valueChanged)
    }
    
    @objc func ratingsInSwitched(_ sender: UISwitch) {
        GlobalSettings.changeRatingsIn(sender.isOn)
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
        let alert = ColoredAlertController(title: "Error", message: "You have to allow notifications for this feature to work. Fix in settings?", preferredStyle: .alert)
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
        case "ratingsIn":
            later()
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
        case "info":
            review()
        default:
            selfExplanatory()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func icons() {
        if #available(iOS 10.3, *) {
            performSegue(withIdentifier: "icons", sender: nil)
        }else{
            let alert = ColoredAlertController(title: "Available only on iOS 10.3, or later", message: "To use this feature you have to update your software", preferredStyle: .alert)
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
        ratingsInSwitch.isOn = GlobalSettings.ratingsIn
    }
    
    func selfExplanatory() {
        let alert = ColoredAlertController(title: "🤔", message: "Well, this is really self-explanatory. Try it and see for yourself!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay, don't be mad!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func review() {
        let alert = ColoredAlertController(title: "", message: "If you enjoy using Plum, please leave a review in the App Store.\nFollow Twitter and Facebook profile for any news regarding Plum's development 😁", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainRatingsIn() {
        let alert = ColoredAlertController(title: "Rating buttons?", message: "Choose whether you're interested in seeing songs' ratings in", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainLyrics() {
        let alert = ColoredAlertController(title: "Lyrics mode? What?", message: "If enabled, you will get lyrics for now playing song delivered right to your lockscreen. And they will change automatically too. It only works with lyrics embedeed in song's tags, Plum does not download lyrics from the internet", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainPlaylistGrid() {
        let alert = ColoredAlertController(title: "Playlists grid?", message: "If enabled, playlists view will become a grid instead of default table", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainDeploy() {
        let alert = ColoredAlertController(title: "Where do we land, general?", message: "You can choose whether you prefer to start playing an album, artist, or all songs, when starting playback from Spotlight or in-app search screen\nIf there is only one song in chosen destination, Plum will start playing all songs", preferredStyle: .actionSheet)
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
//        let alert = ColoredAlertController(title: "Colorflow? What does that mean!?", message: "Easy there, ColorFlow is a cool and one of Plum's unique features that changes colors on now playing screen to match current playing song's artwork. And it looks awesome.", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
//        alert.addAction(ok)
//        present(alert, animated: true, completion: nil)
//    }
    
    func explainStyle(){
        let alert = ColoredAlertController(title: "Time for decision", message: "Choose preferred theme", preferredStyle: .alert)
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
//        let mixed = UIAlertAction(title: "Mixed", style: .default, handler: {(action) in
//            GlobalSettings.changeTheme(.mixed)
//            self.reload()
//            self.updateTheme()
//        })
        alert.addAction(light)
        alert.addAction(dark)
        //alert.addAction(mixed)
        present(alert, animated: true, completion: nil)
    }
    
    func themeAlert() {
        let a = ColoredAlertController(title: "Changing theme?", message: "Please restart the app for all changes to be enabled", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        a.addAction(ok)
        present(a, animated: true, completion: nil)
    }
    
    func explainMiniPlayer(){
        let alert = ColoredAlertController(title: "Time for decision", message: "Classic: iOS 9 music app styleModern: iOS 10 music app style\n\nModern: iOS 10 music app style", preferredStyle: .actionSheet)
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
        let alert = ColoredAlertController(title: "High contrast?", message: "If enabled, background will be purely black, this mode is great for OLED screens like in the iPhone X", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Cool!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func explainArtistsGrid(){
        let alert = ColoredAlertController(title: "Artists grid?", message: "If enabled, artists view will become a grid instead of default table", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }
    
    func explainAlbumsGrid(){
        let alert = ColoredAlertController(title: "Albums grid?", message: "If enabled, albums view will become a grid instead of default table", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)

    }
    
    func explainrating(){
        let alert = ColoredAlertController(title: "Rating Mode?", message: "If enabled, you'll see ratings for each song right from the song view and also you will be able to rate current song from Lockscreen/ControlCenter", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Understood, thanks!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    func later() {
        let alert = ColoredAlertController(title: "😓", message: "Unfortunately this feature is not yet available, it will be enabled in near future!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Can't wait!", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func updateTheme() {
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
        ratingsInL.textColor = UIColor.mainLabel
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
        browserBtn.tintColor = GlobalSettings.tint.color
        facebookBtn.tintColor = GlobalSettings.tint.color
        twitterBtn.tintColor = GlobalSettings.tint.color
        mailBtn.tintColor = GlobalSettings.tint.color
        storeBtn.tintColor = GlobalSettings.tint.color
        authorLabel.textColor = UIColor.mainLabel
        appNameLabel.textColor = UIColor.mainLabel
        attributedInfo()
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

extension SettingsVC {  //Kontakt/Info
    
    func attributedInfo() {
        let plum = NSMutableAttributedString(string: "Plum ")
        let musicplayer = NSMutableAttributedString(string: "Music Player")
        let createdby = NSMutableAttributedString(string: "Created by ")
        let author = NSMutableAttributedString(string: "Adam Wienconek")
        let plumRange = NSRange(location: 0, length: plum.length)
        let musicplayerRange = NSRange(location: 0, length: musicplayer.length)
        let createdbyRange = NSRange(location: 0, length: createdby.length)
        let authorRange = NSRange(location: 0, length: author.length)
        plum.addAttributes([
            NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ], range: plumRange)
        author.addAttributes([
            NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .semibold)
            ], range: authorRange)
        plum.append(musicplayer)
        createdby.append(author)
        appNameLabel.attributedText = plum
        authorLabel.attributedText = createdby
    }
    
    func setVersion() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        versionLabel.text = "Version: \(version)"
        browserBtn.imageView?.contentMode = .scaleAspectFit
        twitterBtn.imageView?.contentMode = .scaleAspectFit
        facebookBtn.imageView?.contentMode = .scaleAspectFit
        mailBtn.imageView?.contentMode = .scaleAspectFit
        storeBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    @IBAction func twitterPressed() {
        openTwitter()
    }
    
    @IBAction func facebookPressed() {
        openFacebook()
    }
    
    @IBAction func browserPressed() {
        openBrowser()
    }
    
    @IBAction func mailPressed() {
        openMail()
    }
    
    @IBAction func storePressed() {
        openStore()
    }
    
    func openTwitter() {
        let twUrl = "twitter://user?screen_name=plumplayer"
        let twUrlWeb = "https://twitter.com/plumplayer"
        UIApplication.tryURL(urls: [twUrl, twUrlWeb])
    }
    
    func openFacebook() {
        //137448817046361
        let fbUrl = "fb://profile/137448817046361"
        let fbUrlWeb = "http://www.facebook.com/137448817046361"
        UIApplication.tryURL(urls: [fbUrl, fbUrlWeb])
    }
    
    func openBrowser() {
        let plUrl = URL(string: "https://plummusicplayer.wordpress.com/")
        UIApplication.shared.open(plUrl!, options: [:], completionHandler: nil)
    }
    
    func openMail() {
        let email = URL(string: "mailto:wiencheck@googlemail.com")
        UIApplication.shared.open(email!, options: [:], completionHandler: nil)
    }
    
    func openStore() {
        let store = URL(string: "https://itunes.apple.com/us/app/plum-music-player/id1331897871?mt=8")
        UIApplication.shared.open(store!, options: [:], completionHandler: nil)
    }
    
}
