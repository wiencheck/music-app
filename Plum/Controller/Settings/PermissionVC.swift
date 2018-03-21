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
    
    var timet: Timer!
    @IBOutlet weak var text: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timet = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(check), userInfo: nil, repeats: true)
        timet.fire()
    }
    
    @IBAction func doneBtn(_ sender: Any){
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    @objc func check() {
        if checkPermissionForMusic() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.letGo()
            UserDefaults.standard.set(1, forKey: "launchesCount")
            performSegue(withIdentifier: "granted", sender: nil)
            timet.invalidate()
        }else{
            print("Waiting for permission...")
        }
    }
    
    private func checkPermissionForMusic() -> Bool {
        switch MPMediaLibrary.authorizationStatus() {
        case .authorized:
            return true
        default:
            return false
        }
    }
}
