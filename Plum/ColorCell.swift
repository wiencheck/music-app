//
//  ColorCell.swift
//  Plum
//
//  Created by Adam Wienconek on 15.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var label: UILabel!
    
    func setup(color: Color) {
        colorView.backgroundColor = color.color
        label.text = color.name
    }
}
