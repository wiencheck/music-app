//
//  CollectionActionCell.swift
//  Plum
//
//  Created by Adam Wienconek on 24.11.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

enum CollectionAction {
    case now
    case next
    case shuffle
}

protocol CollectionActionCellDelegate {
    func cell(_ cell: CollectionActionCell, action: CollectionAction)
}

class CollectionActionCell: UICollectionViewCell {
    
    var delegate: CollectionActionCellDelegate?
    
    @IBAction func playNow() {
        delegate?.cell(self, action: .now)
    }
    
    @IBAction func playNext() {
        delegate?.cell(self, action: .next)
    }
    
    @IBAction func Shuffle() {
        delegate?.cell(self, action: .shuffle)
    }
    
}
