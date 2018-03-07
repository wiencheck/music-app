//
//  PurchaseVC.swift
//  Plum
//
//  Created by Adam Wienconek on 01.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseVC: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func purchasePressed() {
        checkUserBoughtApp()
    }

}

extension PurchaseVC: SKRequestDelegate {  //IAP stuff
    
    func checkUserBoughtApp() {
        let appUrl = Bundle.main.appStoreReceiptURL
        do{
            let t = try appUrl?.checkResourceIsReachable()
            if t! {
                let request = SKReceiptRefreshRequest(receiptProperties: nil)
                request.delegate = self
                request.start()
            }
        }catch let err{
            print(err)
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if request.isKind(of: SKReceiptRefreshRequest.self) {
            print("App is bought")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error)
    }
    
}
