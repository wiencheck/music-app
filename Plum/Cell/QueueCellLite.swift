//
//  QueueCellLite.swift
//  Plum
//
//  Created by Adam Wienconek on 06.12.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

class QueueCellLite: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    
    func setup(_title: String, _artist: String) {
        title.text = _title
        artist.text = _artist
    }
}
