//
//  AppDelegate.swift
//  myPlayer
//
//  Created by Adam Wienconek on 26.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import CoreSpotlight
import UserNotifications
import NotificationCenter
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var remote: RemoteCommandManager!
    var query: musicQuery!
    var auth: Bool?
    var s: UIStoryboard!
    var defaults: UserDefaults!
    var rating: Bool!
    let widget = NCWidgetController.widgetController()
    var ratingDisplayed = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        defaults = UserDefaults.standard
        if let _ = MPMediaQuery.songs().items {
            widget.setHasContent(true, forWidgetWithBundleIdentifier: "com.wiencheck.plum.upnext")
            let count = defaults.integer(forKey: "launchesCount")
            if count % 3 == 0 {
                if #available(iOS 10.3, *){
                    let shortestTime: UInt32 = 5
                    let longestTime: UInt32 = 10
                    guard let timeInterval = TimeInterval(exactly: arc4random_uniform(longestTime - shortestTime) + shortestTime) else { return true }
                    Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(requestReview), userInfo: nil, repeats: false)
                }
            }
            defaults.set(count+1, forKey: "launchesCount")
            print("Launch number \(count+1)")
            letGo()
        }else{
            defaults.set(1, forKey: "launchesCount")
            hijack()
        }
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType{
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                let type = uniqueIdentifier.components(separatedBy: " ")
                if type[0] == "song" {
                    let id = MPMediaEntityPersistentID(type[1])
                    let item = musicQuery.shared.songForID(ID: id!)
                    switch GlobalSettings.deployIn {
                    case .artist:
                        Plum.shared.isShuffle = true
                        if musicQuery.shared.songsByArtistID(artist: item.albumArtistPersistentID).count == 1 {
                            Plum.shared.landInSongs(item, new: true)
                        }else{
                            Plum.shared.landInArtist(item, new: true)
                        }
                    case .album:
                        Plum.shared.isShuffle = true
                        if musicQuery.shared.albumBy(item: item).songsIn == 1 {
                            Plum.shared.landInSongs(item, new: true)
                        }else{
                            Plum.shared.landInAlbum(item, new: true)
                        }
                    case .songs:
                        Plum.shared.isShuffle = true
                        Plum.shared.landInSongs(item, new: true)
                    }
                }else if type[0] == "list" {
                    print("spotlight lista")
                    let id = MPMediaEntityPersistentID(type[1])
                    let list = musicQuery.shared.playlistForID(playlist: id!)
                    Plum.shared.createDefQueue(items: list.items)
                    Plum.shared.defIndex = Int(arc4random_uniform(UInt32(list.songsIn)))
                    Plum.shared.shuffleCurrent()
                    Plum.shared.playFromShufQueue(index: 0, new: true)
                }
                Plum.shared.play()
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if #available(iOS 10.0, *) {
            if GlobalSettings.lyrics && Plum.shared.player.rate != 0.0 {
                Plum.shared.postLyrics()
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if #available(iOS 10.0, *) {
            Plum.shared.removeLyrics()
        }
        Plum.shared.shouldPost = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if #available(iOS 10.0, *) {
            Plum.shared.removeLyrics()
        }
        widget.setHasContent(false, forWidgetWithBundleIdentifier: "com.wiencheck.plum.upnext")
    }

    func setAuth(_ auth: Bool){
        self.auth = auth
    }
    
    func hijack() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "perm")
        
        self.window?.rootViewController = initialViewController
    }
    
    func letGo() {
        GlobalSettings.remote = RemoteCommandManager()
        setInitialSettings()
        readSettings()
        setCustomizing()
        setInitialInstructions()
        setColors()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "plumTab")
        
        self.window?.rootViewController = initialViewController
        let tabBar = self.window?.rootViewController as! PlumTabBarController
        var junkViewControllers = [UIViewController]()
        // returns 0 if not set, hence having the tabItem's tags starting at 1.
        var tagNumber : Int = defaults.integer(forKey: "0")
        if (tagNumber != 0) {
            for i in 0 ..< (tabBar.viewControllers?.count)! {
                // the tags are between 1-6 but the order of the
                // viewControllers in the array are between 0-5
                // hence the "-1" below.
                print(i)
                tagNumber = defaults.integer( forKey: String(i) ) - 1
                junkViewControllers.append(tabBar.viewControllers![tagNumber])
            }
            
            tabBar.viewControllers = junkViewControllers
        }
    }
    
    func setInitialSettings(){
        if defaults.value(forKey: "device") == nil {
            defaults.set(UIDevice.current.modelName, forKey: "device")
        }
        if defaults.value(forKey: "colorFlow") == nil{
            defaults.set(true, forKey: "colorFlow")
        }
        if defaults.value(forKey: "blur") == nil{
            defaults.set(false, forKey: "blur")
        }
        if defaults.value(forKey: "tintName") == nil{
            defaults.set("Plum purple", forKey: "tintName")
            defaults.set(0.21, forKey: "tintRed")
            defaults.set(0.24, forKey: "tintGreen")
            defaults.set(0.61, forKey: "tintBlue")
            defaults.set(1.0, forKey: "tintAlpha")
        }
        if defaults.value(forKey: "artistsGrid") == nil{
            defaults.set(false, forKey: "artistsGrid")
        }
        if defaults.value(forKey: "albumsGrid") == nil{
            defaults.set(true, forKey: "albumsGrid")
        }
        if defaults.value(forKey: "playlistsGrid") == nil{
            defaults.set(false, forKey: "playlistsGrid")
        }
        if defaults.value(forKey: "rating") == nil {
            defaults.set(false, forKey: "rating")
        }
        if defaults.array(forKey: "searchHistory") == nil{
            defaults.set([""], forKey: "searchHistory")
        }
        if defaults.value(forKey: "modernPopup") == nil{
            defaults.set(false, forKey: "modernPopup")
        }
        if defaults.stringArray(forKey: "ratings") == nil {
            let arr = ["★★★★★", "★☆☆☆☆", "Disable rating mode"]
            defaults.set(arr, forKey: "ratings")
        }
        if defaults.value(forKey: "lyrics") == nil{
            defaults.set(false, forKey: "lyrics")
        }
        if defaults.value(forKey: "theme") == nil {
            defaults.set("Light", forKey: "theme")
        }
        if defaults.value(forKey: "deploy") == nil {
            defaults.set("Album", forKey: "deploy")
        }
        if defaults.value(forKey: "scale") == nil {
            defaults.set(20, forKey: "scale")
        }
        if defaults.value(forKey: "playlistsGrid") == nil{
            defaults.set(true, forKey: "playlistsGrid")
        }
        if defaults.value(forKey: "albumsGrid") == nil{
            defaults.set(false, forKey: "albumsGrid")
        }
        if defaults.value(forKey: "artistsGrid") == nil{
            defaults.set(false, forKey: "artistsGrid")
        }
        if defaults.value(forKey: "artistAlbumsSort") == nil {
            defaults.set("alphabetically", forKey: "artistAlbumsSort")
        }
        if defaults.value(forKey: "roundedCorners") == nil {
            defaults.set(true, forKey: "roundedCorners")
        }
        if defaults.value(forKey: "doubleBar") == nil {
            defaults.set(false, forKey: "doubleBar")
        }
        if defaults.value(forKey: "roundedSlider") == nil {
            defaults.set(false, forKey: "roundedSlider")
        }
        if defaults.value(forKey: "searchOnTop") == nil {
            defaults.set(true, forKey: "searchOnTop")
        }
        if defaults.value(forKey: "oled") == nil {
            defaults.set(false, forKey: "oled")
        }
    }
    
    func readSettings(){
        if let dev = defaults.string(forKey: "device") {
            print("Reading device: \(dev)")
            GlobalSettings.setDevice(dev)
        }
        if let rats = defaults.array(forKey: "ratings") as? [String] {
            print("Ratingi = \(rats)")
            var en = [Rating]()
            for i in 0 ..< rats.count {
                en.append(Rating(rawValue: rats[i])!)
            }
            GlobalSettings.updateRatings(en)
        }
        if let fu = defaults.value(forKey: "fullRating") as? Bool {
            GlobalSettings.full = fu
        }
        if let alp = defaults.value(forKey: "artistSort") as? String{
            GlobalSettings.changeArtistSort(Sort(rawValue: alp)!)
        }
        if let alb = defaults.value(forKey: "artistAlbumsSort") as? String{
            GlobalSettings.changeArtistAlbumsSort(Sort(rawValue: alb)!)
        }
        if let pop = defaults.value(forKey: "modernPopup") as? Bool{
            if pop {
                GlobalSettings.changePopupStyle(.modern)
            }else {
                GlobalSettings.changePopupStyle(.classic)
            }
        }
        if defaults.value(forKey: "tintName") == nil{
            defaults.set("Plum purple", forKey: "tintName")
            defaults.set(0.21, forKey: "tintRed")
            defaults.set(0.24, forKey: "tintGreen")
            defaults.set(0.61, forKey: "tintBlue")
            defaults.set(1.0, forKey: "tintAlpha")
        }
        if let col = defaults.value(forKey: "tintName") as? String {
            let red = defaults.value(forKey: "tintRed") as! CGFloat
            let green = defaults.value(forKey: "tintGreen") as! CGFloat
            let blue = defaults.value(forKey: "tintBlue") as! CGFloat
            let alpha = defaults.value(forKey: "tintAlpha") as! CGFloat
            GlobalSettings.changeTint(Color(n: col, c: UIColor(red:red, green:green, blue:blue, alpha:alpha), b: .white))
        }
        if let the = defaults.value(forKey: "theme") as? String {
            GlobalSettings.changeTheme(Theme(rawValue: the)!)
        }
        if let blu = defaults.value(forKey: "blur") as? Bool {
            GlobalSettings.changeBlur(blu)
        }
        if let dou = defaults.value(forKey: "doubleBar") as? Bool {
            GlobalSettings.changeDoubleBar(dou)
        }
        if let dep = defaults.value(forKey: "deploy") as? String {
            GlobalSettings.changeDeploy(Deploy(rawValue: dep)!)
        }
        if let sca = defaults.value(forKey: "scale") as? Double {
            GlobalSettings.changeScale(sca)
        }
        if defaults.bool(forKey: "rating") {
            GlobalSettings.changeRating(defaults.bool(forKey: "rating"))
        }else if defaults.bool(forKey: "lyrics") {
            if #available(iOS 10.0, *) {
                GlobalSettings.changeLyrics(defaults.bool(forKey: "lyrics"))
            }
        }
        if let alg = defaults.value(forKey: "albumsGrid") as? Bool {
            GlobalSettings.changeAlbums(grid: alg)
        }
        if let arg = defaults.value(forKey: "artistsGrid") as? Bool {
            GlobalSettings.changeArtists(grid: arg)
        }
        if let plg = defaults.value(forKey: "playlistsGrid") as? Bool {
            GlobalSettings.changePlaylists(grid: plg)
        }
        if let roun = defaults.value(forKey: "roundedSlider") as? Bool {
            GlobalSettings.changeRound(roun)
        }
        if let sea = defaults.value(forKey: "searchOnTop") as? Bool {
            GlobalSettings.changeSearchOnTop(sea)
        }
        if let oled = defaults.value(forKey: "oled") as? Bool {
            GlobalSettings.changeOled(oled)
        }
        GlobalSettings.changeColor(true)    //do zrobienia ciemny blur
    }
    
    func setCustomizing() {
        UITabBar.appearance().tintColor = GlobalSettings.tint.color
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: GlobalSettings.tint.color], for: .selected)
        UIBarButtonItem.appearance().tintColor = GlobalSettings.tint.color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UISwitch.appearance().tintColor = GlobalSettings.tint.color
        UISwitch.appearance().onTintColor = GlobalSettings.tint.color
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        let s = UIView()
        s.backgroundColor = GlobalSettings.tint.color.withAlphaComponent(1)
        UITableViewCell.appearance().selectedBackgroundView = s
    }
    
    func setInitialInstructions() {
        if defaults.value(forKey: "greeting") == nil {
            defaults.set(false, forKey: "greeting")
        }
        if defaults.value(forKey: "index") == nil {
            defaults.set(false, forKey: "index")
        }
        if defaults.value(forKey: "list") == nil {
            defaults.set(false, forKey: "list")
        }
        if defaults.value(forKey: "grid") == nil {
            defaults.set(false, forKey: "grid")
        }
        if defaults.value(forKey: "songs") == nil {
            defaults.set(false, forKey: "songs")
        }
        if defaults.value(forKey: "playing") == nil {
            defaults.set(false, forKey: "playing")
        }
        if defaults.value(forKey: "swipe") == nil {
            defaults.set(false, forKey: "swipe")
        }
        if defaults.value(forKey: "add") == nil {
            defaults.set(false, forKey: "add")
        }
        if defaults.value(forKey: "tap") == nil {
            defaults.set(false, forKey: "tap")
        }
        if defaults.value(forKey: "delete") == nil {
            defaults.set(false, forKey: "delete")
        }
        if defaults.value(forKey: "deploy") == nil {
            defaults.set(false, forKey: "deploy")
        }
        if defaults.value(forKey: "lyrics") == nil {
            defaults.set(false, forKey: "lyrics")
        }
        if defaults.value(forKey: "rating") == nil {
            defaults.set(false, forKey: "rating")
        }
        if defaults.value(forKey: "spotlight") == nil {
            defaults.set(false, forKey: "spotlight")
        }
        if defaults.value(forKey: "upslider") == nil {
            defaults.set(false, forKey: "upslider")
        }
        if defaults.value(forKey: "artistslider") == nil {
            defaults.set(false, forKey: "artistslider")
        }
        if defaults.value(forKey: "slider") == nil {
            defaults.set(false, forKey: "slider")
        }
        if defaults.value(forKey: "miniplayer") == nil {
            defaults.set(false, forKey: "miniplayer")
        }
    }
    
    private func setColors() {
        if GlobalSettings.theme == .dark {
            if GlobalSettings.oled {
                UIColor.background = UIColor.black
            }else{
                UIColor.background = UIColor.darkBackground
            }
            UIStatusBarStyle.themed = UIStatusBarStyle.lightContent
            UIColor.mainLabel = UIColor.white
            UIColor.detailLabel = UIColor.lightGray
            UIColor.separator = UIColor.darkSeparator
            UIColor.indexBackground = UIColor.black
        }else{
            UIColor.mainLabel = UIColor.black
            UIColor.detailLabel = UIColor.gray
            UIColor.separator = UIColor.lightSeparator
            UIColor.background = UIColor.lightBackground
            UIColor.indexBackground = UIColor.white
            UIStatusBarStyle.themed = UIStatusBarStyle.default
        }
    }
    
    @available(iOS 10.3, *) @objc func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
}

