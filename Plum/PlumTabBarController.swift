//
//  PlumTabBarController.swift
//  wiencheck
//
//  Created by Adam Wienconek on 17.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class PlumTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.theme
        self.tabBar.tintColor = GlobalSettings.theme
        self.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: GlobalSettings.theme], for: UIControlState.normal)
        self.tabBar.unselectedItemTintColor = UIColor.gray
        delegate = self
        self.viewControllers?.forEach {
            if let navController = $0 as? UINavigationController {
                let _ = navController.topViewController?.view
            } else {
                let _ = $0.view.description
            }
        }
        /*if let firstNav = self.viewControllers?.first as? UINavigationController{
            if let first = firstNav.viewControllers.first as? SearchVC{
                self.selectedIndex = 1
            }else{
                self.selectedIndex = 0
            }
        }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let search = SearchVC()
        let songs = SongsVC()
        let artists = ArtistsVC()
        let albums = AlbumsVC()
        let controllers = [search, songs, artists, albums]
        //self.viewControllers = controllers
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
