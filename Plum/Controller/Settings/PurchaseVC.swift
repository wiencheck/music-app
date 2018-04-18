//
//  PurchaseVC.swift
//  Plum
//
//  Created by Adam Wienconek on 01.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseVC: UITableViewController {
    
    @IBOutlet weak var donateBtn: UIButton!
    @IBOutlet weak var donateSegment: UISegmentedControl!
    
    var chosenDonationID = ""
    var donationProductIndex = 1
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        setSegmentedTitles()
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = { [weak self] type in
            switch type {
            case .purchased:
                self?.presentAlert(title: "Thank you!", message: nil)
            default:
                print("Nuffin")
            }
        }
        donateSegment.addTarget(self, action: #selector(segmentSwitch(_:)), for: .valueChanged)
    }
    
    func donate() {
        IAPHandler.shared.purchaseMyProduct(index: donationProductIndex)
    }
    
    @IBAction func donePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func segmentSwitch(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            chosenDonationID = "tip.1"
            donationProductIndex = 1
        case 1:
            chosenDonationID = "tip.2"
            donationProductIndex = 2
        case 2:
            chosenDonationID = "tip.3"
            donationProductIndex = 3
        default:
            chosenDonationID = "tip.4"
            donationProductIndex = 4
        }
    }
    
    func setSegmentedTitles() {
        donateSegment.setTitle("Tier 1", forSegmentAt: 0)
        donateSegment.setTitle("Tier 2", forSegmentAt: 1)
        donateSegment.setTitle("Tier 3", forSegmentAt: 2)
        donateSegment.setTitle("Tier 4", forSegmentAt: 3)
        donateBtn.setTitle("Donate", for: .normal)
    }
}

extension PurchaseVC {
    func setTheme() {
        tableView.separatorColor = UIColor.separator
        view.backgroundColor = UIColor.background
        guard let bar = navigationController?.navigationBar else { return }
        if GlobalSettings.theme == .dark {
            bar.barStyle = .blackTranslucent
        }else{
            bar.barStyle = .default
        }
        bar.tintColor = GlobalSettings.tint.color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.mainLabel]
        donateSegment.tintColor = GlobalSettings.tint.color
        donateBtn.setTitleColor(GlobalSettings.tint.color, for: .normal)
    }
}

extension PurchaseVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if let identifier = cell.reuseIdentifier {
            switch identifier {
            case "donate":
                donate()
            default:
                _ = 0
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func presentAlert(title: String?, message: String?) {
        let alert = ColoredAlertController(title: title, message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
}

/* Validate App Store receipt */
//extension PurchaseVC: SKRequestDelegate {
//
//    func getAppReceipt() {
//        guard let receiptURL = receiptURL else {  /* receiptURL is nil, it would be very weird to end up here */  return }
//        do {
//            let receipt = try Data(contentsOf: receiptURL)
//            validateAppReceipt(receipt)
//        } catch {
//            // there is no app receipt, don't panic, ask apple to refresh it
//            let appReceiptRefreshRequest = SKReceiptRefreshRequest(receiptProperties: nil)
//            appReceiptRefreshRequest.delegate = self
//            appReceiptRefreshRequest.start()
//            // If all goes well control will land in the requestDidFinish() delegate method.
//            // If something bad happens control will land in didFailWithError.
//        }
//    }
//
//    func requestDidFinish(_ request: SKRequest) {
//        // a fresh receipt should now be present at the url
//        do {
//            let receipt = try Data(contentsOf: receiptURL!) //force unwrap is safe here, control can't land here if receiptURL is nil
//            validateAppReceipt(receipt)
//        } catch {
//            // still no receipt, possible but unlikely to occur since this is the "success" delegate method
//        }
//    }
//
//    func request(_ request: SKRequest, didFailWithError error: Error) {
//        print("app receipt refresh request did fail with error: \(error)")
//        presentAlert(title: "Error", message: "app receipt refresh request did fail with error: \(error)")
//        // for some clues see here: https://samritchie.net/2015/01/29/the-operation-couldnt-be-completed-sserrordomain-error-100/
//    }
//
//    func validateAppReceipt(_ receipt: Data) {
//
//        /*  Note 1: This is not local validation, the app receipt is sent to the app store for validation as explained here:
//         https://developer.apple.com/library/content/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1
//         Note 2: Refer to the url above. For good reasons apple recommends receipt validation follow this flow:
//         device -> your trusted server -> app store -> your trusted server -> device
//         In order to be a working example the validation url in this code simply points to the app store's sandbox servers.
//         Depending on how you set up the request on your server you may be able to simply change the
//         structure of requestDictionary and the contents of validationURLString.
//         */
//        let base64encodedReceipt = receipt.base64EncodedString()
//        let requestDictionary = ["receipt-data":base64encodedReceipt]
//        guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
//        do {
//            let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
//            let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
//            guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
//            let session = URLSession(configuration: URLSessionConfiguration.default)
//            var request = URLRequest(url: validationURL)
//            request.httpMethod = "POST"
//            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
//            let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
//                if let data = data , error == nil {
//                    do {
//                        let appReceiptJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
//                        if let org = appReceiptJSON!["receipt"] as? [String: Any] {
//                            guard let version = org["original_application_version"] as? String else { return }
//                            if let fversion = Float(version) {
//                                print("Version = \(fversion)")
//                                self.presentAlert(title: "Success", message: "You have bought \(fversion) version of Plum")
////                                if fversion < 2.0 {
////                                    print("Kupione!")
////                                    self.handleBuyEvent(success: true)
////                                    self.presentAlert(title: "Success!", message: "Thank you for buying Plum and have a great time!")
////                                }
//                            }
//                        }
//                        // if you are using your server this will be a json representation of whatever your server provided
//                    } catch let error as NSError {
//                        print("json serialization failed with error: \(error)")
//                    }
//                } else {
//                    print("the upload task returned an error: \(String(describing: error?.localizedDescription))")
//                }
//            }
//            task.resume()
//        } catch let error as NSError {
//            print("json serialization failed with error: \(error)")
//        }
//    }
//}

