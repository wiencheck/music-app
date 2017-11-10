//
//  SettingsVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 31.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

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
    @IBOutlet weak var indexVisibleSwitch: UISwitch!
    @IBOutlet weak var progressBar: UIProgressView!
    var colorFlowStatus: Bool!
    var artistsGridStatus: Bool!
    var albumsGridStatus: Bool!
    var spotlightStatus: Bool!
    var playlistsGridStatus: Bool!
    var ratingStatus: Bool!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer(timeInterval: 1, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        tabBarController?.delegate = self
        musicQuery.shared.delegate = self
        spotlightButton.alpha = 1.0
        progressBar.alpha = 0.0
        handleSwitches()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = GlobalSettings.theme
    }
    
    func handleSwitches(){
        colorFlowSwitch.addTarget(self, action: #selector(colorSwitched(_:)), for: .valueChanged)
        artistsGridSwitch.addTarget(self, action: #selector(artistsGrid(_:)), for: .valueChanged)
        albumsGridSwitch.addTarget(self, action: #selector(albumsGrid(_:)), for: .valueChanged)
        playlistsGridSwitch.addTarget(self, action: #selector(playlistsGrid(_:)), for: .valueChanged)
        spotlightSwitch.addTarget(self, action: #selector(spotlight(_:)), for: .valueChanged)
        ratingSwitch.addTarget(self, action: #selector(rating(_:)), for: .valueChanged)
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
        /*if Plum.shared.isPlayin(){
            let alert = UIAlertController(title: "Confirm", message: "You will have to restart the app for this feature to work. This will get fixed in near future.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "No prob!", style: .default, handler: {(action) in
                self.ratingStatus = false
            })
            let noAction = UIAlertAction(title: "Let me finish the song first", style: .cancel, handler: {(action) in
                self.ratingStatus = true
            })
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true, completion: nil)
        }else{
            ratingStatus = sender.isOn
        }*/
        ratingStatus = sender.isOn
        GlobalSettings.changeRatingMode(ratingStatus)
        ratingSwitch.isOn = ratingStatus
        defaults.set(ratingStatus, forKey: "ratingMode")
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
                self.spotlightButton.isEnabled = false
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
        self.spotlightButton.setTitle("Done!", for: .disabled)
    }
    
    @objc func updateProgressBar(){
        print("set prog \(musicQuery.shared.progress)")
        self.progressBar.setProgress(musicQuery.shared.progress, animated: false)
        print(musicQuery.shared.progress)
        if self.progressBar.progress >= 100 {
            indexingEnded()
        }
    }
    
    func indexingEnded() {
        timer.invalidate()
        UIView.animate(withDuration: 0.3, animations: {
            self.progressBar.alpha = 0.0
            self.spotlightButton.alpha = 1.0
        })
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
                explainColorFlow()
            }else if indexPath.row == 1{
                explainBlur()
            }
            if indexPath.row == 2{
                explainStyle()
            }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                explainRatingMode()
            }else if indexPath.row == 1{
                explainSpotlight()
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
        if musicQuery.shared.hasLibraryChanged(){
            spotlightButton.isEnabled = true
            spotlightButton.setTitle("Re-index content", for: .normal)
        }else{
            if spotlightStatus{
                spotlightButton.isEnabled = true
                spotlightButton.setTitle("Begin indexing!", for: .normal)
            }
        }
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
