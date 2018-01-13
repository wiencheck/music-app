//
//  ArrayExt.swift
//  wiencheck
//
//  Created by Adam Wienconek on 18.09.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import ObjectiveC

extension Array{
    public mutating func shuffle(){
        var i = 1
        while (i < count) {
            let random = Int(arc4random_uniform(UInt32(i))) + 1
            if(random != i){
                (self[i], self[random]) = (self[random], self[i])
            }
            i = i + 1
        }
    }
}

private var xoAssociationKey: UInt8 = 0
private var boAssociationKey: Bool = false

extension MPMediaItem {
    var index: Int! {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? Int
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func labelFromRating() -> String {
        switch self.rating{
        case 1:
            return "★☆☆☆☆"
        case 2:
            return "★★☆☆☆"
        case 3:
            return "★★★☆☆"
        case 4:
            return "★★★★☆"
        case 5:
            return "★★★★★"
        default:
            return "☆☆☆☆☆"
        }
    }
}


extension TimeInterval{
    func calculateFromTimeInterval() ->(minute:String, second:String){
        let minute_ = abs(Int((self/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(self.truncatingRemainder(dividingBy: 60)))
        
        let minute = minute_ > 9 ? "\(minute_)" : "\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }

}

extension MPMediaItemCollection{
    var duration: String!{
        get{
            var tmp: TimeInterval = 0
            for i in 0...self.count{
                tmp = tmp + items[i].playbackDuration
            }
            return objc_getAssociatedObject(tmp.calculateFromTimeInterval(), &xoAssociationKey) as? String
        }
    }
}

extension IndexPath{
    func absoluteRow(_ tableView: UITableView) -> Int{
        var rowCount = 0
        for s in 0 ..< section {
            rowCount += tableView.numberOfRows(inSection: s)
        }
        rowCount += row
        return rowCount
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat, x: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat, x: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

extension UIViewController {
    func updatePrompt() {
        let alert = UIAlertController(title: "This feature requires iOS10.0 or later", message: "To use it, you will have to update your firmware", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
}

public func calculateCollectionViewCellSize(itemsPerRow: Int, frame: CGRect) -> CGSize{
    switch itemsPerRow {
    case 2:
        let height = frame.height
        let width = frame.width
        let Waspect: CGFloat = 0.45
        var Haspect: CGFloat = 0.35
        if device == "iPhone X" {
            Haspect = 0.27
        }
        return CGSize(width: width*Waspect, height: height*Haspect)
    case 3:
        let height = frame.height
        let width = frame.width
        let Waspect: CGFloat = 0.29
        var Haspect: CGFloat = 0.22
        if device == "iPhone X" {
            Haspect = 0.18
        }
        return CGSize(width: width*Waspect, height: height*Haspect)
    default:
        return CGSize()
    }
}


