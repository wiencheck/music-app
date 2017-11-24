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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var remote: RemoteCommandManager!
    var query: musicQuery!
    var auth: Bool?
    var s: UIStoryboard!
    var defaults: UserDefaults!
    var rating: Bool!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        _ = GlobalSettings()
        //window = UIWindow(frame: UIScreen.main.bounds)
        //window?.makeKeyAndVisible()
        //s = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        //authorized()
        self.query = musicQuery.shared
        self.query.setArrays()
        //self.remote = RemoteCommandManager()
        GlobalSettings.remote = RemoteCommandManager()
        defaults = UserDefaults.standard
        setInitialSettings()
        readSettings()
        UITabBar.appearance().tintColor = .gray
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .normal)
        UIBarButtonItem.appearance().tintColor = GlobalSettings.tint.color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UISwitch.appearance().tintColor = GlobalSettings.tint.color
        UISwitch.appearance().onTintColor = GlobalSettings.tint.color

        // Getting access to your tabBarController
        let tabBar: UITabBarController = self.window?.rootViewController as! UITabBarController
        
        var junkViewControllers = [UIViewController]()
        
        // returns 0 if not set, hence having the tabItem's tags starting at 1.
        var tagNumber : Int = defaults.integer(forKey: "0")
        
        if (tagNumber != 0) {
            for i in 0 ..< (tabBar.viewControllers?.count)! {
                // the tags are between 1-6 but the order of the
                // viewControllers in the array are between 0-5
                // hence the "-1" below.
                tagNumber = defaults.integer( forKey: String(i) ) - 1
                junkViewControllers.append(tabBar.viewControllers![tagNumber])
            }
            
            tabBar.viewControllers = junkViewControllers
        }
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType{
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                let id = MPMediaEntityPersistentID(uniqueIdentifier)
                let item = musicQuery.shared.songForID(ID: id!)
                switch GlobalSettings.deployIn {
                case .artist:
                    Plum.shared.landInArtist(item, new: true)
                case .album:
                    Plum.shared.landInAlbum(item, new: true)
                default:
                    print("wyladuje w piosenkach")
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
        if GlobalSettings.lyrics && Plum.shared.player.rate != 0.0 {
            Plum.shared.postLyrics()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Plum.shared.removeLyrics()
        Plum.shared.shouldPost = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Plum.shared.removeLyrics()
    }
    
    fileprivate func authorized() {
        MPMediaLibrary.requestAuthorization { (authStatus) in
            switch authStatus {
            case .notDetermined:
                let perm = self.s.instantiateViewController(withIdentifier: "perm") as! PermissionVC
                self.window?.rootViewController = perm
                break
            case .authorized:
                let bar = self.s.instantiateViewController(withIdentifier: "plumTab") as! PlumTabBarController
                self.window?.rootViewController = bar
                break
            default:
                let perm = self.s.instantiateViewController(withIdentifier: "perm") as! PermissionVC
                self.window?.rootViewController = perm
                break
            }
        }
    }

    func setAuth(_ auth: Bool){
        self.auth = auth
    }
    
    func setInitialSettings(){
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
            defaults.set(true, forKey: "artistsGrid")
        }
        if defaults.value(forKey: "albumsGrid") == nil{
            defaults.set(false, forKey: "albumsGrid")
        }
        if defaults.value(forKey: "playlistsGrid") == nil{
            defaults.set(false, forKey: "playlistsGrid")
        }
        if defaults.value(forKey: "bigGrid") == nil{
            defaults.set(true, forKey: "bigGrid")
        }
        if defaults.value(forKey: "spotlightActive") == nil{
            defaults.set(false, forKey: "spotlightActive")
        }
        if defaults.value(forKey: "style") == nil{
            defaults.set(2, forKey: "style")
        }
        if defaults.value(forKey: "fullRating") == nil {
            defaults.set(true, forKey: "fullRating")
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
        if defaults.value(forKey: "landing") == nil{
            defaults.set("album", forKey: "landing")
        }
        if defaults.value(forKey: "lyrics") == nil{
            defaults.set(false, forKey: "lyrics")
        }
        if defaults.value(forKey: "theme") == nil {
            defaults.set("light", forKey: "theme")
        }
        if defaults.value(forKey: "deploy") == nil {
            defaults.set("album", forKey: "deploy")
        }
        if defaults.value(forKey: "scale") == nil {
            defaults.set(57, forKey: "scale")
        }
        if defaults.value(forKey: "slider") == nil {
            defaults.set("Alphabetical", forKey: "slider")
        }
    }
    
    func readSettings(){
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
        if let rat = defaults.value(forKey: "rating") as? Bool{
            GlobalSettings.changeRating(rat, full: GlobalSettings.full)
        }
        if let alp = defaults.value(forKey: "alphabeticalSort") as? Bool{
            GlobalSettings.changeAlphabeticalSort(alp)
        }
        if let pop = defaults.value(forKey: "modernPopup") as? Bool{
            if pop {
                GlobalSettings.changePopupStyle(.modern)
            }else {
                GlobalSettings.changePopupStyle(.classic)
            }
        }
        if let lyr = defaults.value(forKey: "lyrics") as? Bool {
            GlobalSettings.changeLyrics(lyr)
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
            switch the {
            case "light":
                GlobalSettings.changeTheme(.light)
            default:
                GlobalSettings.changeTheme(.dark)
            }
        }
        if let blu = defaults.value(forKey: "blur") as? Bool {
            GlobalSettings.changeBlur(blu)
        }
        if let dep = defaults.value(forKey: "deploy") as? String {
            GlobalSettings.changeDeploy(Deploy(rawValue: dep)!)
        }
        if let sca = defaults.value(forKey: "scale") as? Double {
            GlobalSettings.changeScale(sca)
        }
        if let slid = defaults.value(forKey: "slider") as? String {
            GlobalSettings.changeSlider(Slider(rawValue: slid)!)
        }
    }
}

