//
//  ShuffleCell.swift
//  Plum
//
//  Created by Adam Wienconek on 03.01.2018.
//  Copyright © 2018 Adam Wienconek. All rights reserved.
//

import UIKit

class ShuffleCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    func setup(style: Theme) {
        label.textColor = UIColor.mainLabel
        label.text = "Shuffle"
        icon.image = #imageLiteral(resourceName: "shuffle")
    }

}
