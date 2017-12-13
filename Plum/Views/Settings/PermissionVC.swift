//
//  PermissionVC.swift
//  wiencheck
//
//  Created by Adam Wienconek on 07.10.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit
import MediaPlayer

class PermissionVC: UIViewController {
    
    var query: MPMediaQuery?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = GlobalSettings.tint.color
        self.view.backgroundColor = .red
        displayPermissionsError()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneBtn(_ sender: Any){
        performSegue(withIdentifier: "done", sender: nil)
    }
    
    fileprivate func displayPermissionsError() {
        let alertVC = UIAlertController(title: "This is a demo", message: "Unauthorized or restricted access. Cannot play media. Fix in Settings?" , preferredStyle: .alert)
        
        //cancel
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            })
            alertVC.addAction(settingsAction)
        } else {
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        }
        present(alertVC, animated: true, completion: nil)
    }

}
