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
}

extension AVAudioPlayer{
    var currentItem: MPMediaItem!{
        get{
            let query = MPMediaQuery.songs()
            let predicate = MPMediaPropertyPredicate(value: url, forProperty: MPMediaItemPropertyAssetURL)
            query.addFilterPredicate(predicate)
            return query.items![0]
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


extension String{
    func firstLetter() -> Character{
        var tmp = self.lowercased()
        if tmp.hasPrefix("the "){
            tmp = String(tmp.characters.dropFirst(4))
        }else if tmp.hasPrefix("a "){
            tmp = String(tmp.characters.dropFirst(2))
        }else if tmp.hasPrefix("an "){
            tmp = String(tmp.characters.dropFirst(3))
        }
        let hmm = "aąbcćdeęfghijklmnoópqrsśtuvwxyzżź0123456789"
        let letters = Array(hmm.characters)
        for index in characters.indices{
            if letters.contains(tmp[index]){
                return tmp[index]
            }
        }
        return "_"
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

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}
