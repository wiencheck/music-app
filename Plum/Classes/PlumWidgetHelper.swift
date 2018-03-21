//
//  PlumWidgetHelper.swift
//  Plum
//
//  Created by Adam Wienconek on 06.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import Foundation
import MediaPlayer

class PlumWidgetHelper {
    let player = Plum.shared
    
    func getQueue() -> [MPMediaItem] {
        var items = [MPMediaItem]()
        var start = 0
        var meta = 0
        var current = 0
        if player.isShuffle {
            current = player.shufIndex
            start = current + 1
            if player.shufQueue.count > current + 8 {
                meta = current + 8
            }else{
                meta = player.shufQueue.count
            }
            for i in start ..< meta {
                items.append(player.shufQueue[i])
            }
        }else{
            current = player.defIndex
            start = current + 1
            if player.defQueue.count > current + 8 {
                meta = current + 8
            }else{
                meta = player.defQueue.count
            }
            for i in start ..< meta {
                items.append(player.defQueue[i])
            }
        }
        return items
    }
}
