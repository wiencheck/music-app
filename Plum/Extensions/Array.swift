//
//  Array.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

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
