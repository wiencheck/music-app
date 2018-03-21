//
//  UIApplication.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

extension UIApplication {   //Open URL
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.open(URL(string: url)!, options: [:], completionHandler: nil)
                return
            }
        }
    }
}
