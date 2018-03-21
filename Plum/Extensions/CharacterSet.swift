//
//  CharacterSet.swift
//  Plum
//
//  Created by Adam Wienconek on 21.03.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import Foundation

extension CharacterSet {
    static let latin = CharacterSet.init(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let ESet = CharacterSet(charactersIn: "EĘÈÉÊËĖĒ")
    static let ASet = CharacterSet(charactersIn: "AĄÀÁÂÄÆÃÅĀ")
    static let SSet = CharacterSet(charactersIn: "ŚŠ")
    static let OSet = CharacterSet(charactersIn: "OÓÔÖÒÕŒØŌ")
}
