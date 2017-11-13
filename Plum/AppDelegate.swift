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
        self.remote = RemoteCommandManager()
        GlobalSettings.remote = self.remote
        defaults = UserDefaults.standard
        setInitialSettings()
        readSettings()
        UITabBar.appearance().tintColor = .gray
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for: .normal)
        UIBarButtonItem.appearance().tintColor = GlobalSettings.theme
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]

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
                Plum.shared.landInAlbum(item, new: true)
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
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
        if defaults.value(forKey: "ratingMode") == nil{
            defaults.set(false, forKey: "ratingMode")
        }
        if defaults.array(forKey: "searchHistory") == nil{
            defaults.set([""], forKey: "searchHistory")
        }
        if defaults.value(forKey: "indexVisible") == nil{
            defaults.set(false, forKey: "indexVisible")
        }
        if defaults.value(forKey: "modernPopup") == nil{
            defaults.set(false, forKey: "modernPopup")
        }
        if defaults.value(forKey: "likeMessage") == nil{
            defaults.set("Give 4★", forKey: "likeMessage")
        }
        if defaults.value(forKey: "dislikeMessage") == nil{
            defaults.set("Give 1★", forKey: "dislikeMessage")
        }
        if defaults.value(forKey: "bookmarkMessage") == nil{
            defaults.set("Give 5★", forKey: "bookmarkMessage")
        }
        if defaults.value(forKey: "likeValue") == nil{
            defaults.set(4, forKey: "likeValue")
        }
        if defaults.value(forKey: "dislikeValue") == nil{
            defaults.set(1, forKey: "dislikeValue")
        }
        if defaults.value(forKey: "bookmarkValue") == nil{
            defaults.set(5, forKey: "bookmarkValue")
        }
    }
    
    func readSettings(){
        if let rat = defaults.value(forKey: "ratingMode") as? Bool{
            GlobalSettings.changeRatingMode(rat)
        }
        if let alp = defaults.value(forKey: "alphabeticalSort") as? Bool{
            GlobalSettings.changeAlphabeticalSort(alp)
        }
        if let ind = defaults.value(forKey: "indexVisible") as? Bool{
            GlobalSettings.changeIndexVisibility(ind)
        }
        if let pop = defaults.value(forKey: "modernPopup") as? Bool{
            if pop {
                GlobalSettings.changePopupStyle(.modern)
            }else {
                GlobalSettings.changePopupStyle(.classic)
            }
        }
        if let lik = defaults.value(forKey: "likeMessage") as? String{
            if let licc = defaults.value(forKey: "likeValue") as? Int{
                GlobalSettings.changeFeedbackContent(which: "Like", message: lik, value: licc)
            }
        }
        if let dis = defaults.value(forKey: "dislikeMessage") as? String{
            if let diss = defaults.value(forKey: "dislikeValue") as? Int{
                GlobalSettings.changeFeedbackContent(which: "Dislike", message: dis, value: diss)
            }
        }
        if let bok = defaults.value(forKey: "bookmarkMessage") as? String{
            if let bokk = defaults.value(forKey: "bookmarkValue") as? Int{
                GlobalSettings.changeFeedbackContent(which: "Bookmark", message: bok, value: bokk)
            }
        }
    }
}

