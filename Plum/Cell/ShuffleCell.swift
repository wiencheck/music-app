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

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(style: Theme) {
        if style == Theme.dark {
            label.textColor = UIColor.white
        }else{
            label.textColor = UIColor.black
        }
        label.text = "Shuffle"
        icon.image = #imageLiteral(resourceName: "shuffle")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
